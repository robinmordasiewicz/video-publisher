pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }
//  triggers {
//    upstream(upstreamProjects: "video-publisher-theme,f5-cnf-docs", threshold: hudson.model.Result.SUCCESS)
//  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: ubuntu
            image: robinhoodis/ubuntu:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            imagePullPolicy: IfNotPresent
            command:
            - /busybox/cat
            tty: true
            volumeMounts:
              - name: kaniko-secret
                mountPath: /kaniko/.docker
          restartPolicy: Never
          volumes:
            - name: kaniko-secret
              secret:
                secretName: regcred
                items:
                  - key: .dockerconfigjson
                    path: config.json
        '''
    }
  }
  stages {
    stage('INIT') {
      steps {
        cleanWs()
        checkout scm
      }
    }
    stage('Increment VERSION') {
      when {
        beforeAgent true
        allOf {
          anyOf {
            changeset "Dockerfile"
            changeset "requirements.txt"
          }
          // triggeredBy cause: 'UserIdCause'
          not {changeset "VERSION"}
        }
      }
      steps {
        container('ubuntu') {
          sh 'sh increment-version.sh'
        }
      }
    }
    stage('Build/Push Container') {
      when {
        beforeAgent true
        expression {
          container('ubuntu') {
            sh(returnStatus: true, script: 'skopeo inspect docker://docker.io/robinhoodis/video-publisher:`cat VERSION`') == 1
          }
        }
      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''
            /kaniko/executor --dockerfile=Dockerfile \
                             --context=`pwd` \
                             --destination=robinhoodis/video-publisher:`cat VERSION` \
                             --destination=robinhoodis/video-publisher:latest \
                             --cache=true
            '''
          }
        }
      }
    }
  }
  post {
    always {
      cleanWs(cleanWhenNotBuilt: false,
            deleteDirs: true,
            disableDeferredWipeout: true,
            notFailBuild: true,
            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                       [pattern: '.propsfile', type: 'EXCLUDE']])
    }
  }
}
