docker run \
  -dit \
  -p 8080:8080 \
  -p 50000:50000 \
  --network host \
  -v jenkins_home:/var/jenkins_home \
  --name jenkins \
  jenkins:local
