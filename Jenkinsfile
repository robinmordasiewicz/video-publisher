pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }
//  triggers {
//    upstream(upstreamProjects: "sphinx-theme,f5-cnf-docs", threshold: hudson.model.Result.SUCCESS)
//  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: mlt
            image: robinhoodis/mlt:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
        '''
    }
  }
  stages {
    stage('INIT') {
      when {
        beforeAgent true
        changeset "Jenkinsfile"
      }
      steps {
        cleanWs()
        checkout scm
      }
    }
    stage('checkout docs') {
      when {
        beforeAgent true
        changeset "Jenkinsfile"
      }
      steps {
        sh 'mkdir -p docs'
        dir ( 'docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/f5-cnf-lab.git'
        }
      }
    }
    stage('publish video') {
      when {
        beforeAgent true
        changeset "Jenkinsfile"
      }
      steps {
        dir ( 'docs' ) {
          container('mlt') {
            // sh 'ffmpeg -f concat -filter_complex xfade=transition=slideleft:duration=5:offset=0 -i join.txt -c copy output.mov'
            // sh 'ffmpeg -i join.txt -filter_complex "[0:v]setpts=PTS-STARTPTS[v0];[1:v]setpts=PTS-STARTPTS+4/TB,format=yuva444p,fade=st=4:d=1:t=in:alpha=1[v1];[v0][v1]overlay,format=yuv420p[v];[0:a]asetpts=PTS-STARTPTS[a0];[1:a]asetpts=PTS-STARTPTS[a1];[a0][a1]acrossfade=d=1[a]" -map "[v]" -map "[a]" output.mov'
            sh 'ffmpeg -i clip1.mov -i clip2.mov -i clip3.mov -pix_fmt yuv420p -filter_complex "xfade=transition=fade:offset=60:duration=1" -y out.mov'
          }
        }
      }
    }
    stage('Commit new VERSION') {
      when {
        beforeAgent true
        changeset "Jenkinsfile"
      }
      steps {
        dir ( 'docs' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          // sh 'git add -u'
          // sh 'git diff --quiet && git diff --staged --quiet || git commit -m "`cat VERSION`"'
          sh 'git add . && git diff --staged --quiet || git commit -m "new movie"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            // sh 'git diff --quiet && git diff --staged --quiet || git push origin HEAD:main'
            // sh 'git diff --quiet HEAD || git push origin HEAD:main'
            sh 'git push origin HEAD:main'
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
