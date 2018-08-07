

let spaceShip;
let neighborhood;
var neighborhood_x;
var scene_x;
var scene_y;
var mouse_point;
var angle_sine;
var phase_x = 0;

var socket
function setup() {
 socket = new WebSocket("ws://" + window.location.host + "/websocket");
socket.onopen = function(evt) { onOpen(evt) };
print("start");
//while(socket.readyState !=1){};

print("socket is opend");

socket.onmessage = function (ev) { onMessage(ev) };
createCanvas(windowWidth, windowHeight);
spaceShip = new SpaceShip();
neighborhood = new Neighborhood();
//print(spaceShip.v_pos.x,spaceShip.v_pos.y);
mouse_point = createVector(0, 0); }

function draw() {
	if(keyIsPressed == true)
		move();
			if (mouseIsPressed) {
			spaceShip.shout();
		}
	background(51);
	neighborhood.show();
	spaceShip.update();
	spaceShip.show();

}

function onOpen(evt) {
		print("open");

}
function onMessage(ev) {
	console.log('Received data: ' + ev.data);
  var msg = JSON.parse(ev.data);
	//spaceShip.v_pos.set( msg.x, msg.y);
	print("reacive");
}


function move() {
	var x ,y, angle ;
	y = spaceShip.v_val.y;
	x = spaceShip.v_val.x;
  angle = spaceShip.angle;
	// if (keyCode === UP_ARROW){
	// 	y = y - 0.1; }
	// if (keyCode === LEFT_ARROW){
	// 	angle = angle - 5;}
	// if (keyCode === RIGHT_ARROW){
	// 	angle = angle + 5;}
	// if (keyCode === DOWN_ARROW){
	// 	y = y + 0.1;}



	if (keyCode === UP_ARROW){
		angle_sine = 1;
		if(mouseX < windowWidth/2)
		angle_sine = -1;

			y = y + angle_sine*0.2*sin(angle);
		  x = x + angle_sine*0.2*cos(angle);
		//print(cos(angle),sin(angle))
	}
	var data = {x_val: x, y_val: y };
	//var msg = {type: 'ping', count: 1};
	socket.send(JSON.stringify(data));
	spaceShip.v_val.set(x,y);

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
		var ang_x = mouseX - windowWidth/2;
		//line(windowWidth/2, this.v_pos.y, mouseX,mouseY);
    this.angle = atan(ang_y/ang_x);
		 // push();
		 // mouse_point.set(mouseX-windowWidth/2 ,mouseY-this.v_pos.y);
		 // translate(windowWidth/2 + phase_x, this.v_pos.y);
		 // var temp = createVector(windowWidth/2 + phase_x,this.v_pos.y);
		 // line(0, 0, mouseX-windowWidth/2,mouseY-this.v_pos.y);
		 // this.angle = mouse_point.angleBetween(temp);
		 // pop();
		 this.v_pos.set( this.v_pos.x + this.v_val.x, this.v_pos.y + this.v_val.y);
		 var x = this.v_val.x -  this.v_val.x*0.02*abs(sin(this.angle));
		 var y = this.v_val.y  + 0.02;
     this.v_val.set(x,y);
		// this.v_pos.y = this.v_pos.y + this.v_val.y;
		// this.v_pos = this.v_pos.x + this.v_val.x;
		neighborhood_x = -this.v_pos.x;


		if(this.v_pos.x < windowHeight/2){
			this.v_pos.x = windowHeight/2 ;
			phase_x = phase_x + this.v_val.x;
			if(phase_x < -windowHeight/2 )
				{
					phase_x = -windowHeight/2 -5;
				}

		}

		if(this.v_pos.y > windowHeight){
				this.v_pos.y = windowHeight;
				this.v_val.y = -this.v_val.y+1;
		}
		if(this.v_pos.y < 0){
				this.v_pos.y = 0;
				this.v_val.y = -this.v_val.y-1;
}

	//	print(this.v_pos.y ,this.v_pos.x);
	}

	show(){
		stroke('white');
		strokeWeight(2);
		noFill();
		mouse_point.set(mouseX,mouseY)

	//	x = map(x,0 ,windowWidth,360,0);
		//print(this.angle);
		angleMode(DEGREES);
		push();
		translate(windowWidth/2 + phase_x, this.v_pos.y);
		rotate(this.angle);
		//print(this.v_pos.angleBetween(mouse_point));
		ellipse(0, 0, 20, 5);
		pop();
		//strock(0,0,phase_x, 0);
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
		translate(0,0);
		noFill();
		var i;
		for(i = 0; i<100 ;i++){
		rect(100+neighborhood_x + i*1000, windowHeight-60, 30, 60);
		rect(200+neighborhood_x + i*1000, windowHeight-60, 30, 60);
		rect(300+neighborhood_x + i*1000, windowHeight-60, 30, 60);
		rect(400+neighborhood_x + i*1000, windowHeight-60, 30, 60);
		rect(500+neighborhood_x + i*1000, windowHeight-300, 30, 300);
		rect(600+neighborhood_x + i*1000, windowHeight-60, 30, 60);
		rect(700+neighborhood_x + i*1000, windowHeight-70, 30, 70);
		rect(800+neighborhood_x + i*1000, windowHeight-100, 30, 100);
		rect(900+neighborhood_x + i*1000, windowHeight-200, 30, 200);
	}

	}
}
