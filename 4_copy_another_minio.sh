oldip=$1
oldkey=$2
oldpwd=$3

newip=$4
newkey=$5
newpwd=$6

mc alias set oldminio http://$oldip:9112 $oldkey $oldpwd
mc alias set newminio http://$newip:9112 $newkey $newpwd
mc mirror --overwrite oldminio newminio

for bucket in $(mc ls oldminio | awk '{print $NF}' | sed 's#/##'); do
  policy=$(mc anonymous get oldminio/$bucket | awk -F '`' '{print $4}')
  echo $policy
  if [[ "$policy" != "none" ]]; then
    echo "Setting policy '$policy' for bucket $bucket"
    mc anonymous set $policy newminio/$bucket
  fi
done

#mc admin policy export oldminio <policy-name> > policy.json
#mc admin policy import newminio <policy-name> < policy.json

