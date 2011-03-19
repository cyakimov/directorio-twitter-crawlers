//Run this script in http://www.twitter-venezuela.com/pag/categorias
//to count how many users are in all categories
var patt=/\d+/g;
var text = jQuery("h3").text();
var arr = text.match(patt);
var count = 0;
var i = arr.length;
while(i--)
    count+=parseInt(arr[i])
count