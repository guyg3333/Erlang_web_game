

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
mouse_point = createVector(0, 0); }



function draw() {
	Time ++;

	if(Time == 360){
			var data = {x_acl: 0, y_acl: 0 }; //keep alive
			socket.send(JSON.stringify(data));
			Time = 0;}

	if(keyIsPressed == true){
			if (mouseIsPressed)
					spaceShip.shout();
			move();

  }

		if(reacive_new){
		show(msg);
		reacive_new = false;
	}
}

function show(world){

	background(56);

	spaceShip.v_pos.set( world.x_pos, world.y_pos);
	console.log(world.x_pos, world.y_pos);
	spaceShip.update();
	spaceShip.show();

	for (i in world.other_player){
		ellipse(world.other_player[i].x_pos - world.x_pos + windowWidth/2, msg.other_player[i].y_pos +neighborhood_y, 20, 5);
}
	neighborhood.show();
	print("reacive");
}





function onOpen(evt) {
		print("open");

}
function onMessage(ev) {
	console.log('Received data: ' + ev.data);
  var temp = JSON.parse(ev.data);
	if(temp.type == "world_type"){
		reacive_new = true;
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

	var data = {x_acl: angle_sine*cos(spaceShip.angle), y_acl: angle_sine*sin(spaceShip.angle) };
	socket.send(JSON.stringify(data));
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
    var ang_y = mouseY - this.v_pos.y;
		if(this.v_pos.y + windowHeight/2 < 900)
		     ang_y = mouseY - windowHeight/2;

		var ang_x = mouseX - windowWidth/2;
    this.angle = atan(ang_y/ang_x);
		neighborhood_x = -this.v_pos.x;

	}

	show(){


		stroke('white');
		strokeWeight(2);
		noFill();
		//mouse_point.set(mouseX,mouseY)
		angleMode(DEGREES);

		if(this.v_pos.y + windowHeight/2 >= 900){
		neighborhood_y = windowHeight-900;
		push();
		translate(windowWidth/2, windowHeight - (900 - this.v_pos.y));
		rotate(this.angle);
		//print(this.v_pos.angleBetween(mouse_point));
		ellipse(0, 0, 20, 5);
		pop();
	  }
		else{
		neighborhood_y =  -(this.v_pos.y - windowHeight/2);
		console.log(neighborhood_y);
		push();
		translate(windowWidth/2, windowHeight/2);
		rotate(this.angle);
		//print(this.v_pos.angleBetween(mouse_point));
		ellipse(0, 0, 20, 5);
		pop();

		}
	}






}//calss

class Bulats{
	constructor(angle,spaceShip){
	this.v_pos = createVector(windowWidth/2, spaceShip.v_pos.y);
	this.v_val = createVector(angle_sine*10*cos(angle), angle_sine*10*sin(angle));
	//this.v_val = createVector(3*cos(angle), 3*sin(angle));

	}

update() {
	var x = this.v_pos.x + this.v_val.x;
	var y = this.v_pos.y + this.v_val.y;
	this.v_pos.set(x,y);}

show(){
	line(this.v_pos.x, this.v_pos.y,this.v_pos.x+3,this.v_pos.y+3); }

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
