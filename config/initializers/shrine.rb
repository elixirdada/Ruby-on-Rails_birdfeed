require "shrine/storage/s3"

s3_options = {
  access_key_id:     ENV['S3_KEY'],
  secret_access_key: ENV['S3_SECRET'],
  bucket:            ENV['S3_BUCKET_NAME'],
  region:            ENV['S3_REGION'],
}

Shrine.storages = {
  store: Shrine::Storage::S3.new(**s3_options)
}

Shrine.plugin :presign_endpoint, presign_options: { method: :put, acl: 'public-read' }
