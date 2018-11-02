---
title: Express 使用 nodemon 、gulp、 browser-sync 实现自动刷新
date: 2018-05-22 21:56:43
categories:
- 技术
tags:
- express
- nodemon
- browser-sync
- gulp
- swig
---

在 Webpack 盛行的今日，感觉用 Gulp 已经是跟不上时代的表现了。但是研究了一下发现， Webpack 适合前后端分离的项目，而我只是想用 Express 实现一个小功能，使用后端渲染，所以还是简单一点吧，我是觉得只要满足功能就行。  

作为一个后端倒腾一些前端的东西，真的原谅我精力有限，前端的东西学习成本高，适用周期短，过几年就有新东西出来了，所以能用就行了吧。

就是想实现一个修改 html、css 然后浏览器 livereload 的功能。使用标题关键字一搜，几年前的文章就有一把吧。  

踩坑说明，我使用了 swig 模板引擎，虽然这已经是一个不维护的库了，但是谁让我比较熟悉 twig 呢，还是 swig 比较合适我，但是 swig 默认是缓存模板结果的，所以使用之后会发现刷新了浏览器但是没有修改没有生效。因为是先运行刷新浏览器，然后再运行 nodemon ，这在时间上会有前后顺序的差异，可以具体我代码中定义了 `bs-delay`。其实在开发环境设置 swig cache = false 就可以咯。

gulpfile.js 代码详细
<!-- more --> 
```javascript
const gulp = require('gulp');
const nodemon = require('gulp-nodemon');
const browserSync = require('browser-sync').create();

gulp.task('browser-sync', ['nodemon'], function () {
    browserSync.init(null, {
        proxy: "http://localhost:3000",
        port: 5000,
        notify: true
    });
});

gulp.task('default', ['browser-sync'], function () {
    gulp.watch('./views/*.html', browserSync.reload);
    gulp.watch('./public/**/*.js', browserSync.reload);
    gulp.watch('./public/**/*.css', browserSync.reload);
    gulp.watch(['**/*.js', '!node_modules/**/*.js'], ['bs-delay']);
});

gulp.task('bs-delay', function () {
    setTimeout(function () {
        browserSync.reload();
    }, 300);
});

gulp.task('nodemon', function (cb) {
    var started = false;
    return nodemon({
        script: 'index.js',
        ext: 'js html',
        ignore: [
            'gulpfile.js',
            'node_modules/'
        ],
        env: {
            'NODE_ENV': 'development',
        }
    }).on('start', function () {
        if (!started) {
            cb();
            started = true;
        }
    }).on('crash', function () {
        console.log('nodemon.crash');
    }).on('restart', function () {
        console.log('nodemon.restart');
    }).once('quit', function () {
        console.log('nodemon.quit');
        process.exit();
    });
});
```

