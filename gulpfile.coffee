gulp = require 'gulp'
coffee = require 'gulp-coffee'
coffeeify = require 'gulp-coffeeify'
coffeelint = require 'gulp-coffeelint'
livereload = require 'gulp-livereload'
nodemon = require 'gulp-nodemon'
notify = require 'gulp-notify'
plumber = require 'gulp-plumber'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
watch = require 'gulp-watch'

cfg = require './config/gulp'

gulp.task 'default', ['build', 'livereload', 'nodemon', 'watch']

gulp.task 'nodemon', ->
  nodemon
    script: 'app.coffee'
    tasks: ['lint']
    ext: 'coffee'
    ignore: ['client', 'views']
  .on 'restart', ->
    livereload.reload()

gulp.task 'livereload', ->
  livereload.listen()

gulp.task 'build', ['scripts', 'lint']

gulp.task 'scripts', ->
  gulp.src cfg.scripts
  .pipe plumber()
  .pipe sourcemaps.init()
  .pipe coffeeify()
  .pipe uglify()
  .pipe sourcemaps.write('./')
  .pipe gulp.dest('public/js')
  .pipe livereload()
  .pipe notify(message: 'coffee build completed')

gulp.task 'views', ->
  gulp.src cfg.views
  .pipe livereload()
  .pipe notify(message: 'views refreshed')

gulp.task 'lint', ->
  gulp.src cfg.lint
  .pipe plumber()
  .pipe coffeelint()
  .pipe coffeelint.reporter()
  .pipe notify(message: 'coffeelint done')

gulp.task 'watch', ->
  watch cfg.client, ->
    gulp.start 'build'
  watch cfg.views, ->
    gulp.start 'views'
