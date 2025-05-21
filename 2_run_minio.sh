docker run -d --name minio \
  -p 9112:9112 -p 9001:9001 \
  -v /mnt/minio-data:/data \
  -e "MINIO_ROOT_USER=" \
  -e "MINIO_ROOT_PASSWORD=" \
  quay.io/minio/minio server /data --console-address ":9001" --address ":9112"

