# jenkins-with-docker
Im Rahmen der [link](https://openshift-usergroup.de/ "OpenShift Usergroup Dortmund/Ruhrgebiet") wurde das Thema "" vorgestellt. Als Beispiel dazu gibt es hier das Dockerfile für den im Vortrag erwähnten Jenkins-Container. Den Folien des Vortrags gibt es hier: [link](https://openshift-usergroup.de/unser-zweites-meeting "2. Meeting der UserGroup")
Zusätzlich soll noch das Plugin throttle-concurrents für Jenkins installiert werden. Damit kann man bewirken, dass von einer Pipeline/Job immer nur eine zur Zeit läuft. Ich habe dies für Übertragungen verwendet die Nachts laufen, da ältere Versionen von Docker manchmal mit mehreren Übertragungen gleichzeitig nicht gut klar kamen.

Das Ziel des Images ist es, dass man mit Jenkins einen vollwertigen Docker Daemon fernsteuern kann um Images aus anderen Umgebungen zu holen und anschließend in die eigene ImageRegistry zu pushen.

## Verwendung
Das Beispiel ist für die Verwendung auf der OpenShift Container Platform. 

### Jenkins
Das Jenkins Image soll dort auf das Red Hat Jenkins Image aufseetzen. Dafür ist es notwendig, dass ihr in der BuildConfig auf das Jenkins Image in eurem openshift-Namespace verweist. Hier ein Beispiel für die BuildConfig:
```
apiVersion: v1
kind: BuildConfig
metadata:
  name: jenkins-docker
  labels:
    build: jenkins-docker
spec:
  triggers: []
  runPolicy: Serial
  source:
    type: Git
    git:
      uri: 'https://github.com/fmei/jenkins-with-docker.git'
  strategy:
    type: Docker
    dockerStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift
        name: 'jenkins:2'
      noCache: true
  output:
    to:
      kind: ImageStreamTag
      name: 'jenkins-docker:latest'
  resources:
  postCommit:
```
Alles andere könnt ihr genauso machen wie Jenkins Template von OSCP.

### Dind
Im Ordner dind/ ist noch eine Kopie des Docker dind Images für die von mir verwendete Docker Version. Das Original findet ihr auf [link](https://hub.docker.com/_/docker/). Es handelt sich dabei um die Versionen die mit **-dind** getaggt sind. Der Dind-Pod benötigt Root-Rechte, daher sind die folgenden SCCs notwendig. Beispielweise für den ServiceAccount docker:
```
oc create sa docker -n jenkins
oc adm policy add-scc-to-user anyuid system:serviceaccount:jenkins:docker
oc adm policy add-scc-to-user privileged system:serviceaccount:jenkins:docker
```
Die Parameter zum starten von Docker können in der DeploymentConfig mit übergeben werden. Dort könnt ihr auch eure Registry als insecure-registry angeben:

```
apiVersion: v1
kind: DeploymentConfig
metadata:
  name: docker
  labels:
    app: docker
  annotations:
    openshift.io/generated-by: OpenShiftNewApp
spec:
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 1
      intervalSeconds: 1
      timeoutSeconds: 600
      maxUnavailable: 25%
      maxSurge: 25%
    resources:
  replicas: 1
  test: false
  selector:
    app: docker
    deploymentconfig: docker
  template:
    metadata:
      labels:
        app: docker
        deploymentconfig: docker
      annotations:
        openshift.io/container.docker.image.entrypoint: '["docker-entrypoint.sh","sh"]'
    spec:
      containers:
        -
          name: docker
          image: 'usergroup/docker:latest'
          command:
            - docker
            - daemon
            - '-H'
            - 'tcp://0.0.0.0:2375'
            - '--insecure-registry'
            - 'hub.example.com:443'
            - '--ip-forward=false'
            - '--ip-masq=false'
            - '--iptables=false'
          ports:
            -
              containerPort: 2375
              protocol: TCP
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      serviceAccountName: docker
      serviceAccount: docker
```


Anschließend braucht ihr noch einen Service für den Pod und ihr könnt ihn aus dem Jenkins Pod mit docker -H **service**:**port** fernsteuern.
