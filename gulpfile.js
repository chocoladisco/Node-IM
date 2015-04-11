var gulp = require('gulp');
var gutil = require('gulp-util');

var coffee = require('gulp-coffee');
var jade = require('gulp-jade');
var stylus = require('gulp-stylus');

var browserify = require('browserify');
var watchify = require('watchify');

var uglify = require('gulp-uglify');
var minifyHTML = require('gulp-minify-html');
var minifyCSS = require('gulp-minify-css');

gulp.task('default', ['coffee', 'jade', 'stylus'])

gulp.task('coffee', function(){
	//converting coffeescript to javascript
	gulp.src('./src/app.coffee')
		.pipe(coffee({
			bare: true
		}).on('error', gutil.log))
		//.pipe(uglify())
		.pipe(gulp.dest('./dist/'));

	gulp.src('./src/files/js/*.coffee')
		.pipe(coffee({
			bare: true
		}).on('error', gutil.log))
		//.pipe(uglify())
		.pipe(gulp.dest('./dist/files/js/'));
});

gulp.task('jade', function(){
	//converting the jade to html
	var opts = {
		conditionals: true,
    	spare:true
	}

	gulp.src('./src/files/*.jade')
		.pipe(jade())
		.pipe(minifyHTML(opts))
		.pipe(gulp.dest('./dist/files/'))

	gulp.src('./src/files/views/*.jade')
		.pipe(jade())
		.pipe(minifyHTML(opts))
		.pipe(gulp.dest('./dist/files/views/'))
});

gulp.task('stylus', function(){
	//converting the stylus to css
	gulp.src('./src/files/css/*.styl')
		.pipe(stylus())
		.pipe(minifyCSS())
		.pipe(gulp.dest('./dist/files/css/'));
});
