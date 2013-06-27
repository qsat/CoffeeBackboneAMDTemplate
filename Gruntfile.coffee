module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-compass'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-imagemin'
  grunt.loadNpmTasks 'grunt-eco'
  grunt.loadNpmTasks 'grunt-requirejs'
  grunt.loadNpmTasks 'grunt-simple-mocha'

  grunt.initConfig
    connect:
      server:
        options:
          port: 8008
          base: './htdocs'
    exec:
      ctags:
        command: "ctags ./src"

    watch:
      coffee:
        files: "src/**/*.coffee",
        tasks: ["coffee", "exec:ctags"]

      coffee_with_test:
        files: ['src/**/*.coffee', 'test/**/*_test.coffee'],
        tasks: ['coffee:compile', 'simplemocha']

      compass:
        files: 'src/sass/**/*.scss'
        tasks: ['compass']

      options:
        nospawn: true

    jshint:
      all: ['htdocs/js/**/*.js', 'src/test/**/*.js']

    coffee:
      compile:
        expand: true
        #flatten: true
        dest: 'htdocs/js/'
        src: [ "**/*.coffee" ]
        ext: '.js'
        cwd: "src/coffee/"

    compass:
      compile:
        options:
          sassDir: 'src/sass'
          cssDir: 'htdocs/css'
          outputStyle: 'nested'
          environment: 'production'

    jade:
      compile:
        expand: true
        dest: 'htdocs/'
        src: [ "**/*.jade" ]
        ext: '.html'
        cwd: "src/jade/"
        options:
          pretty: true
          debug: false

    imagemin:
      compile:
        expand: true
        dest: 'htdocs/images'
        src: [ "**/*.png", "**/*.jpg" ]
        cwd: "src/images/"
        options:
          optimazationLevel: 3

    simplemocha:
      options:
        globals: ['should']
        timeout: 3000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
        compilers: 'coffee:coffee-script'
      
      all:
        src: 'test/**/*.coffee'

    eco:
      compile:
        expand: true
        src: ['**/*.eco']
        dest: 'htdocs/js/template'
        cwd: "src/coffee/template"
        ext: '.js'
        options:
          amd: true

    requirejs:
      compile:
        options:
          almond: true
          baseUrl: 'htdocs/js'
          mainConfigFile: 'htdocs/js/bootstrap.js'
          out: 'htdocs/js/application.js'
          include: ['bootstrap']
          optimize: 'uglify2'
          generateSourceMaps: true
          preserveLicenseComments: false
          useSourceUrl: true

    compress:
      main:
        options:
          mode: 'gzip'
        files: [ src:'htdocs/js/application.js', dest:'htdocs/js/application.js.gz']

  grunt.event.on 'watch', (action, filepath)->
    path = (confArr)->
      cwd = grunt.config confArr
      [filepath.split(cwd)[1]]

    grunt.config ['coffee', 'compile', 'src'], path ['coffee', 'compile', 'cwd']
    grunt.config ['imagemin', 'compile', 'src'], path ['imagemin', 'compile', 'cwd']
    grunt.config ['jade', 'compile', 'src'], path ['jade', 'compile', 'cwd']

  grunt.registerTask "run", ["coffee", "connect", "watch:coffee"]
  grunt.registerTask "build", ["coffee", "requirejs", "compress"]
