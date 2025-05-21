master_key=$1
master_pwd=$2
ip=$3
bucket=$4
slave_name=$5
mc replicate add \
	--remote-bucket http://$master_key:$master_pwd@$ip:9112/$bucket \
#       --sync \
        $slave_name/$bucket
