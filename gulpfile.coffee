gulp = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'compile_coffee', () ->
  gulp.src(['**/*.coffee', 'index.coffee', '!node_modules/**/*.coffee'])
    .pipe(coffee())
    .pipe gulp.dest 'build/'

gulp.task 'default', ['compile_coffee']