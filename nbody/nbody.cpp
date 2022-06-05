#define _USE_MATH_DEFINES
 
#include <cmath>
#include <iostream>
#include <vector>

// Constants
const double solar_mass = 4 * M_PI * M_PI;
const double days_per_year = 365.24;

class Body {
    public:
        double x;
        double y;
        double z;
        double vx;
        double vy;
        double vz;
        double mass;
    
// https://stackoverflow.com/questions/268587/can-i-use-identical-names-for-fields-and-constructor-parameters
        Body ( double x, 
            double y, 
            double z, 
            double vx, 
            double vy, 
            double vz, 
            double mass )
        {
            this->x = x;
            this->y = y;
            this->z = z;
            this->vx = vx;
            this->vy = vy;
            this->vz = vz;
            this->mass = mass;
        }

        void offset_momentum (double px, double py, double pz)
        {
            vx = -px / solar_mass;
            vy = -py / solar_mass;
            vz = -pz / solar_mass;
        }
};

void init_sun(std::vector<Body*>& bodies){
    double px = 0.0;
    double py = 0.0;
    double pz = 0.0;
    for(int i = 0; i < bodies.size(); i++){
        px += bodies[i]->vx * bodies[i]->mass;
        py += bodies[i]->vy * bodies[i]->mass;
        pz += bodies[i]->vz * bodies[i]->mass;
    }
    std::cout << bodies[0]->vx << std::endl;
    bodies[0]->offset_momentum(px, py, pz);
    std::cout << bodies[0]->vx << std::endl;
}

std::vector<Body*> perf_nbody(){
    Body sun = Body(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, solar_mass);

    Body jupiter = Body( 4.84143144246472090e+00,
                        -1.16032004402742839e+00,
                        -1.03622044471123109e-01,
                        1.66007664274403694e-03 * days_per_year,
                        7.69901118419740425e-03 * days_per_year,
                        -6.90460016972063023e-05 * days_per_year,
                        9.54791938424326609e-04 * solar_mass );

    Body saturn = Body( 8.34336671824457987e+00,
                        4.12479856412430479e+00,
                        -4.03523417114321381e-01,
                        -2.76742510726862411e-03 * days_per_year,
                        4.99852801234917238e-03 * days_per_year,
                        2.30417297573763929e-05 * days_per_year,
                        2.85885980666130812e-04 * solar_mass );   

    Body uranus = Body( 1.28943695621391310e+01,
                        -1.51111514016986312e+01,
                        -2.23307578892655734e-01,
                        2.96460137564761618e-03 * days_per_year,
                        2.37847173959480950e-03 * days_per_year,
                        -2.96589568540237556e-05 * days_per_year,
                        4.36624404335156298e-05 * solar_mass ); 

    Body neptune = Body( 1.53796971148509165e+01,
                        -2.59193146099879641e+01,
                        1.79258772950371181e-01,
                        2.68067772490389322e-03 * days_per_year,
                        1.62824170038242295e-03 * days_per_year,
                        -9.51592254519715870e-05 * days_per_year,
                        5.15138902046611451e-05 * solar_mass );

    Body *sun_p = &sun;
    Body *jupiter_p = &jupiter;
    Body *saturn_p = &saturn;
    Body *uranus_p = &uranus;
    Body *neptune_p = &neptune;


    std::vector<Body*> bodies {
        sun_p,
        jupiter_p,
        saturn_p,
        uranus_p,
        neptune_p
    };

    return bodies;
}

int main()
{
    // Body b = Body(0.5,0.5,0.5,0.5,0.5,0.5,0.5);
    // std::cout << b.mass << std::endl;
    // std::cout << "Solar mass: " << solar_mass << std::endl;
    // std::cout << "Days per year: " << days_per_year << std::endl;
    // b.offset_momentum(1.0,1.0,1.0);
    // std::cout << "After offset momentum: " << b.vx << std::endl;
    std::vector<Body*> bodies = perf_nbody();
    init_sun(bodies);
    // for (int i=0; i < bodies.size(); i++){
    //     std::cout << bodies[i]->vx << std::endl;
    // }
}