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

// void init_sun(std::vector<Body> bodies){
//     double px = 0.0;
//     double py = 0.0;
//     double pz = 0.0;
//     for(int i = 0; i < bodies.size(); i++){
//         px += bodies[i].vx * bodies[i].mass;
//         py += bodies[i].vy * bodies[i].mass;
//         pz += bodies[i].vz * bodies[i].mass;
//     }
//     bodies[1].offset_momentum(px, py, pz);
// }

int main()
{
    Body b = Body(0.5,0.5,0.5,0.5,0.5,0.5,0.5);
    std::cout << b.mass << std::endl;
    std::cout << "Solar mass: " << solar_mass << std::endl;
    std::cout << "Days per year: " << days_per_year << std::endl;
    b.offset_momentum(1.0,1.0,1.0);
    std::cout << "After offset momentum: " << b.vx << std::endl;
}