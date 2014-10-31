module.exports.authentication =

  domain: "http://localhost:1337"

  token:
    secret : 'sailorjs4win'

    endpoints:
      'user': ['post', 'delete']
      'user/login': 'post'

    options:
      algorithm : 'HS256'
      # expired time in minutes
      expiration: 10080 # 7 days
