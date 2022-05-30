#!/bin/bash
ROOT_PATH=/export/server/
HADOOP_PATH=$ROOT_PATH/hadoop
ZK_PATH=$ROOT_PATH/zookeeper
HBASE_PATH=$ROOT_PATH/hbase
KAFKA_PATH=$ROOT_PATH/kafka
HIVE_PATH=$ROOT_PATH/hive

WORKERS=(node1 node2 node3)
ZK_WORKERS=(${WORKERS[*]})
HBASE_WORKERS=(${WORKERS[*]})



read -p "请确保你在master机器执行本脚本[y/n]：" resp
case $resp in
	y|ye|yes)
		echo "开始执行..."
	;;
	*)
		echo "程序退出..."
		exit
	;;
esac

read -p "是否启动HDFS[y/n]:" resp
case $resp in
	y|ye|yes)
		echo "开始启动 HDFS......"
		$HADOOP_PATH/sbin/start-dfs.sh
		echo "启动完成 HDFS......"
	;;
	*)
		echo "不启动 HDFS......"
	;;
esac

read -p "是否启动YARN[y/n]:" resp
case $resp in
	y|ye|yes)
		echo "开始启动 YARN......"
		$HADOOP_PATH/sbin/start-yarn.sh
		$HADOOP_PATH/sbin/yarn-daemon.sh start proxyserver
		$HADOOP_PATH/sbin/mr-jobhistory-daemon.sh start historyserver
		echo "启动完成 YARN......"
	;;
	*)
		echo "不启动 YARN......"
	;;
esac

read -p "是否启动Zookeeper[y/n]:" resp
case $resp in
	y|ye|yes)
		echo "开始启动 Zookeeper......"
		for node in "${ZK_WORKERS[@]}"
		do
			echo "开始启动${node}的Zookeeper服务......"
			ssh $node "${ZK_PATH}/bin/zkServer.sh start" >> /dev/null
		done
		echo "启动完成 Zookeeper......"
	;;
	*)
		echo "不启动 Zookeeper......"
	;;
esac

read -p "是否启动HBase[y/n]:" resp
case $resp in
	y|ye|yes)
		echo "开始启动 HBase......"
		$HBASE_PATH/bin/start-hbase.sh
		echo "启动完成 HBase......"
	;;
	*)
		echo "不启动 HBase......"
	;;
esac


echo "脚本执行完成......"
