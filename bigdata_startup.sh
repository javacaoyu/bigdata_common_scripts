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
KAFKA_WORKERS=(${WORKERS[*]})



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

read -p "是否启动HDFS集群[y/n]:" resp
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

read -p "是否启动YARN集群[y/n]:" resp
case $resp in
	y|ye|yes)
		echo "开始启动 YARN......"
		$HADOOP_PATH/sbin/start-yarn.sh
		echo "开始启动 代理服务器......"
		$HADOOP_PATH/sbin/yarn-daemon.sh start proxyserver
		echo "开始启动 历史服务器......"
		$HADOOP_PATH/sbin/mr-jobhistory-daemon.sh start historyserver
		echo "启动完成 YARN......"
	;;
	*)
		echo "不启动 YARN......"
	;;
esac

read -p "是否启动Zookeeper集群[y/n]:" resp
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

read -p "是否启动HBase集群[y/n]:" resp
case $resp in
	y|ye|yes)
		echo "开始启动 HBase......"
		$HBASE_PATH/bin/start-hbase.sh
		echo "开始启动 HBase ThriftServer......"
		$HBASE_PATH/bin/hbase-daemon.sh start thrift
		echo "启动完成 HBase......"
	;;
	*)
		echo "不启动 HBase......"
	;;
esac

read -p "是否启动Kafka集群[y/n]:" resp
case $resp in
	y|ye|yes)
		echo "开始启动 Kafka......"
		for node in "${KAFKA_WORKERS[@]}"
		do
			echo "开始启动${node}的Kafka服务......"
			ssh $node "$KAFKA_PATH/bin/kafka-server-start.sh $KAFKA_PATH/config/server.properties 2>&1 >> $KAFKA_PATH/kafka-server.log &"
		done
		echo "启动完成 Kafka......"
	;;
	*)
		echo "不启动 Kafka......"
	;;
esac


echo "脚本执行完成......"
