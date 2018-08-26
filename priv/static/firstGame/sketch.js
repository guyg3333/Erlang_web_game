

let spaceShip;
let neighborhood;
var neighborhood_x;
var neighborhood_y;
var scene_x;
var scene_y;
var mouse_point;
var angle_sine;
var phase_x = 0;
var socket

var msg
var reacive_new = false;
var Time = 0;
var alive = true;

var scr_lo_x;
var scr_lo_y;

var bullet_counter;

function setup() {
socket = new WebSocket("ws://" + window.location.host + "/websocket");
socket.onopen = function(evt) { onOpen(evt) };
print("start");
//while(socket.readyState !=1){};

print("socket is opend");

socket.onmessage = function (ev) { onMessage(ev) };
socket.onclose = function(evt){ onClose(evt) };
socket.onerror = function(e) { onError(evt)};
createCanvas(windowWidth, windowHeight);
spaceShip = new SpaceShip();
neighborhood = new Neighborhood();
//print(spaceShip.v_pos.x,spaceShip.v_pos.y);
scr_lo_x = windowWidth/2;
scr_lo_y = windowHeight/2;
angle_sine = 1;
bullet_counter = 0;
mouse_point = createVector(0, 0); }




function show_scoure(status,scoure){
    textSize(25);
  	text("Statuse : " + status, 10, 40);
  	text("Scoure : " + scoure, 10, 70);
}

function draw_spaceShip(strok){

  strokeWeight(2);
	ellipse(0, 0, 40, 20);
	ellipse(0, -5, 20, 15);
}


function draw_spaceShip(x,y,status){
  strokeWeight(2);
  if(status == "dead")
  stroke('red');
	ellipse(x, y, 40, 20);
	ellipse(x, y-5, 20, 15);
  stroke('white');

}



function draw() {
Time ++;


if(Time == 360){
			var data = {type : "player" , x_acl: 0, y_acl:0}; //keep alive
			socket.send(JSON.stringify(data));
			Time = 0;}

if ( mouseIsPressed && bullet_counter ==0 && alive == true){
	   bullet_counter = 60;
     shout(); }

if(keyIsPressed == true && alive == true)
		 move();

if(reacive_new){
		show(msg);
		reacive_new = false;}

 if(bullet_counter > 0)
    bullet_counter--;
}//main draw

function shout() {

var xx_val =  100*angle_sine*cos(spaceShip.angle);
var yy_val =  100*angle_sine*sin(spaceShip.angle);
console.log('xx_val' , xx_val);
console.log('yy_val' , yy_val);


var data = {x_val: xx_val ,
            y_val: yy_val ,
            x_pos: spaceShip.v_pos.x,
            y_pos: spaceShip.v_pos.y,
            type: "bullet"};
socket.send(JSON.stringify(data));
console.log('shout' , data);

}

function show(world){

	background(56);

	spaceShip.v_pos.set( world.x_pos, world.y_pos);
	spaceShip.update();
	spaceShip.show();

	for (i in world.other_player){
		draw_spaceShip(world.other_player[i].x_pos - world.x_pos + windowWidth/2, msg.other_player[i].y_pos +neighborhood_y,msg.other_player[i].state);
}

for (i in world.bullets){
  line(world.bullets[i].x_start - world.x_pos + windowWidth/2, world.bullets[i].y_start +neighborhood_y,
    world.bullets[i].x_end - world.x_pos + windowWidth/2, world.bullets[i].y_end +neighborhood_y);
}


	neighborhood.show();
  show_scoure(world.state,world.scoure);
}//show


function onOpen(evt) {
		print("open");

}
function onMessage(ev) {
	console.log('Received data: ' + ev.data);
  var temp = JSON.parse(ev.data);
	if(temp.type == "world_type"){
		reacive_new = true;
    if(temp.state =="dead")
       alive = false;
		msg = temp;
	}
}

function onClose(evt){
		console.log('connection close');
}

function onError(evt)  {
	console.log("WebSocket Error: " , evt);
}


function move() {

	if (keyCode === UP_ARROW){
		angle_sine = 1;
		if(mouseX < windowWidth/2)
		angle_sine = -1;

    var temp22 = 1;
	  var data = {type : "player" ,x_acl: angle_sine*cos(spaceShip.angle), y_acl: angle_sine*sin(spaceShip.angle) };
	 socket.send(JSON.stringify(data));
   console.log('move');

  }
	//spaceShip.v_val.set(x,y);
}






class SpaceShip {
constructor(){
	this.v_pos = createVector(windowWidth/2, 200);
	this.v_val = createVector(0, 0);
	this.angle = 0;
	this.Array_of_Bullat = [];
	// this.x_pos =  200;
	// this.y_pos = 200;
	// this.y_val =  0;
	// this.x_val =  0;
}

shout(){
   let bullet = new Bulats(this.angle,this);
	 append(this.Array_of_Bullat,bullet);
}
	update() {
 		var num_of_bullet = this.Array_of_Bullat.length;
		if(num_of_bullet!=0)
		{
			var i;
			for(i=0;i<num_of_bullet;i++){
				this.Array_of_Bullat[i].update();
				this.Array_of_Bullat[i].show();
			}
		}
		neighborhood_x = -this.v_pos.x;
	}

	show(){
    if(msg.state == "dead")
		  stroke('red');
		strokeWeight(2);
		noFill();
		//mouse_point.set(mouseX,mouseY)
		angleMode(DEGREES);
                var ang_x = mouseX - windowWidth/2;
                var ang_y = mouseY - windowHeight/2;


		if(this.v_pos.y + windowHeight/2 >= 900){
		neighborhood_y = windowHeight-900;
		ang_y = mouseY - (windowHeight+ -900+this.v_pos.y);
                scr_lo_y = windowHeight+ -900+this.v_pos.y;
                this.angle = atan(ang_y/ang_x);
		push();
		translate(windowWidth/2, windowHeight - (900 - this.v_pos.y));
		rotate(this.angle);
		//print(this.v_pos.angleBetween(mouse_point));
                ellipse(0, 0, 40, 20);
	        ellipse(0,-5, 20, 15);
		pop();
	  }
		else{
		scr_lo_y = windowHeight/2;
		neighborhood_y =  -(this.v_pos.y - windowHeight/2);
                this.angle = atan(ang_y/ang_x);
		push();
		translate(windowWidth/2, windowHeight/2);
		rotate(this.angle);
		//print(this.v_pos.angleBetween(mouse_point));
		ellipse(0, 0, 40, 20);
	        ellipse(0,-5, 20, 15);
		pop();
		}
             //line(scr_lo_x,scr_lo_y,mouseX,mouseY);
             //fill('red');
	    // triangle(-40 + mouseX, mouseY, scr_lo_x, scr_lo_y, 40 + mouseX, mouseY);
	     //noFill();
       stroke('white');

	}//show






}//calss

class Bulats{
	constructor(angle,spaceShip){
	this.v_pos = createVector(scr_lo_x, scr_lo_y);
	this.v_val = createVector(angle_sine*100*cos(spaceShip.angle), angle_sine*100*sin(spaceShip.angle));
	//this.v_val = createVector(3*cos(angle), 3*sin(angle));

	}

update() {
	var x = this.v_pos.x + this.v_val.x;
	var y = this.v_pos.y + this.v_val.y;
	this.v_pos.set(x,y);}

show(){
	line(this.v_pos.x, this.v_pos.y,this.v_pos.x + this.v_val.x,this.v_pos.y + this.v_val.y); }

} // class


class Neighborhood{
	constructor(){
		neighborhood_x = 0;
	}



	show(){
		stroke('white');
		strokeWeight(2);
		//translate(0,0);
		line(-100, 900+ neighborhood_y, 10000, 900+ neighborhood_y);
		line(-100, 0+ neighborhood_y, 10000, 0+ neighborhood_y);
		noFill();
		var i;
		for(i = 0; i<100 ;i++){
		rect(100+neighborhood_x + i*1000, 900-60 + neighborhood_y, 30, 60);
		rect(200+neighborhood_x + i*1000, 900-60 + neighborhood_y, 30, 60);
		rect(300+neighborhood_x + i*1000, 900-60 + neighborhood_y, 30, 60);
		rect(400+neighborhood_x + i*1000, 900-60 + neighborhood_y, 30, 60);
		rect(500+neighborhood_x + i*1000, 900-300 +neighborhood_y, 30, 300);
		rect(600+neighborhood_x + i*1000, 900-60 + neighborhood_y, 30, 60);
		rect(700+neighborhood_x + i*1000, 900-70 + neighborhood_y, 30, 70);
		rect(800+neighborhood_x + i*1000, 900-100 +neighborhood_y, 30, 100);
		rect(900+neighborhood_x + i*1000, 900-200 +neighborhood_y, 30, 200);
	}

	}
}
