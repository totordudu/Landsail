final float degToRad = PI/180;
final float radToDeg = 180/PI;
final float PII = 2*PI;

class Landsail{
    //float w = 44, float l = 58, float sailArea = 0.3, float sailborder = 58,  float mass = 1
    public Landsail(float w, float l, float sailArea, float sailborder,  float mass){
        _pos = new PVector(0,0);        // (Float) in m and °
        _heading = PI;
        _speed = 0;                 // (Float) in m/s
        _sailOpenning = PI/6;       // (Float) Between 90° and 0°
        _sailMomentum = 0;
        _sailAngularSpeed = 0;
        _wheelAngle = 0;
        _width = w;
        _lenght = l;
        _sailBorder = sailborder;
        _sailArea = sailArea;
        _mass = mass;
        _accel = 0;
        _dragForce = 0;
        _rollForce = 0.3*9.81*mass;
        _goal = new PVector(150,-200);
    }


    public void autoPilot(){
        PVector rGoal = new PVector(_goal.x, _goal.y);
        rGoal.sub(_pos);
        float goalAngle = 0;
        if(rGoal.y > 0 )goalAngle = acos(rGoal.x / rGoal.mag());
        if(rGoal.y < 0 )goalAngle = -acos(rGoal.x / rGoal.mag());

        drawVector(_pos.x, _pos.y, 100, goalAngle, color(255,255,255));

        _heading = (_heading + PII) % PII;
        goalAngle = (goalAngle + PII) % PII;
    
        _wheelAngle%=PII;
        float incAngle = (goalAngle - _heading - PI/2) - _wheelAngle;

        //println(incAngle * radToDeg);

        if(incAngle + _wheelAngle > wheelLimit){
            incAngle = 0;
        }else if(incAngle + _wheelAngle < -wheelLimit){
            incAngle = 0;
        }

        _wheelAngle += incAngle;
        _wheelAngle%=PII;


        if(_speed < 3){
            accelerate();
        }else{
            decelerate();
        }
    }

    public void debug(){
        pushMatrix();
            translate(-width/2, -height/2);
            fill(200);
            rect(0,25,300,300);
            fill(0);
            strokeWeight(0.5);
            textSize(15);
            
            text("_heading :", 10, 50);         text(_heading*radToDeg, 200,50);
            text("_speed :", 10,100);           text(_speed, 200,100);
            text("_sailOpenning :", 10,150);    text(_sailOpenning*radToDeg, 200,150);
            text("_sailAngularSpeed :", 10,200);text(_sailAngularSpeed*radToDeg, 200,200);
            text("_sailMomentum :", 10,250);    text(_sailMomentum*radToDeg, 200,250);
        popMatrix();
    }

    public void computeSpeed(){
       _heading = (_heading + PII) % PII;

        float lambda = _heading + _sailOpenning - Wind.direction();
        _sailMomentum = (Wind.speed()/3600) * _sailBorder * cos(lambda);

        _sailAngularSpeed += _sailMomentum * 0.003;

        if(_sailOpenning + _sailAngularSpeed >= sailLimit){
            _sailAngularSpeed = 0;
        }else if(_sailOpenning + _sailAngularSpeed <= -sailLimit){
            _sailAngularSpeed = 0;
        }

        _sailOpenning += _sailAngularSpeed;
        _sailOpenning%=PII;

        _sailAngularSpeed -= 0.08*_sailAngularSpeed;

        
        float alpha =  _heading + _sailOpenning + Wind.direction();
        
        float a = cos((Wind.direction() - (_heading + _sailOpenning)+PII)%PII) * (Wind.speed()/3600);
        a -= _speed*0.02;

        _speed += a;

        float radius = _lenght / cos((PI/2) - _wheelAngle);
        float beta = _speed / radius;

        _heading += beta;

        _pos.add(new PVector(_speed * -sin(_heading), _speed * cos(_heading)));
    }

    public void display(){
        Wind.draw(_pos.x, _pos.y);
        float cx = 1,cy = 1;
        stroke(color(0,0,0));
        fill(color(255,255,255));
        pushMatrix();
            translate(_goal.x, _goal.y);
            ellipse(0, 0, 10, 10);
        popMatrix();
        pushMatrix();
            translate(_pos.x*cx, _pos.y*cy);
            rotate(_heading);

            beginShape();
                vertex(0,0);
                vertex(-_width/2, -_lenght);
                vertex(0, (-2*_lenght)/3);
                vertex(_width/2, -_lenght);
            endShape(CLOSE);

            rotate(_wheelAngle);
            line(0,0,0,_lenght/8);
            rotate(-_wheelAngle);
            rotate(_sailOpenning);
            line(0,0,0,-_lenght);

        popMatrix();
    }

    public void goTo(float x, float y){
        _goal = new PVector(x,y);
    }

    public void setPos(PVector pos){
        _pos = pos;
        _heading = pos.z + PI;
        if(_heading > 2*PI) _heading -= 2*PI;
        if(_heading < 0) _heading += 2*PI;
    }

    public PVector getPos(){
        return _pos;
    }

    public void setSpeed(float s){
        _speed = s;
    }

    public float getSpeed(){
        return _speed;
    }

    public void steerLeft(){
        _wheelAngle -= PI/24;
        if(_wheelAngle < -PI/4) _wheelAngle = -PI/4;
    }

    public void steerRight(){
        _wheelAngle += PI/24;
        if(_wheelAngle > PI/4) _wheelAngle = PI/4;
    }

    public void accelerate(){
        _speed += 1;
        if(_speed > 10) _speed = 10;
    }

    public void decelerate(){
        _speed -= 2.5;
        if(_speed < 0) _speed = 0;
    }


 
    private PVector _pos, _goal;
    private float   _heading, _wheelAngle,
                    _speed, _mass, _accel,
                    _rollForce, _dragForce,
                    _sailOpenning, _sailAngularSpeed, _sailMomentum,
                    _sailBorder,
                    _width, _lenght,
                    _sailArea;

    final float sailLimit = 45 * degToRad,
                wheelLimit = 45 * degToRad;
};