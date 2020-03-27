/************ Include Files ************/
#include "MotorFeedback.h"
#include "PmodDHB1.h"
#include "PWM.h"
#include "sleep.h"
#include "xil_cache.h"


/************ Macro Definitions ************/
#define GPIO_BASEADDR     XPAR_PMODDHB1_0_AXI_LITE_GPIO_BASEADDR
#define PWM_BASEADDR      XPAR_PMODDHB1_0_PWM_AXI_BASEADDR
#define MOTOR_FB_BASEADDR XPAR_PMODDHB1_0_MOTOR_FB_AXI_BASEADDR

#ifdef __MICROBLAZE__
#define CLK_FREQ XPAR_CPU_M_AXI_DP_FREQ_HZ
#else
#define CLK_FREQ 100000000 // FCLK0 frequency not found in xparameters.h
#endif

#define PWM_PER              2
#define SENSOR_EDGES_PER_REV 4
#define GEARBOX_RATIO        48


/************ Function Prototypes ************/
void MotorInitialize();

void DemoRun();

void MotorCleanup();

void drive(int16_t sensor_edges);

void EnableCaches();

void DisableCaches();

void turnLeft(int steps);

void turnRight(int steps);

void moveForward(int steps);

void moveBackward(int steps);


/************ Global Variables ************/
PmodDHB1 pmodDHB1;
MotorFeedback motorFeedback;


/************ Function Definitions ************/
int main(void) {
   MotorInitialize();

   DHB1_setMotorSpeeds(&pmodDHB1, 20, 20);
   MotorFeedback_clearPosCounter(&motorFeedback);
   printf("tt");
   while(1){
	   DemoRun();
   }
   MotorCleanup();
   return 0;
}

void MotorInitialize() {
   EnableCaches();
   DHB1_begin(&pmodDHB1, GPIO_BASEADDR, PWM_BASEADDR, CLK_FREQ, PWM_PER);
   MotorFeedback_init(
      &motorFeedback,
      MOTOR_FB_BASEADDR,
      CLK_FREQ,
      SENSOR_EDGES_PER_REV,
      GEARBOX_RATIO
   );
   DHB1_motorDisable(&pmodDHB1);
}

void DemoRun() {

   moveForward(240);

   moveBackward(240);

   turnRight(120);

   turnLeft(120);
}

void MotorCleanup() {
   DisableCaches();
}

void drive(int16_t sensor_edges) {
   DHB1_motorEnable(&pmodDHB1);
   int16_t dist = MotorFeedback_getDistanceTraveled(&motorFeedback);
   while (dist < sensor_edges) {
      dist = MotorFeedback_getDistanceTraveled(&motorFeedback);
   }
   MotorFeedback_clearPosCounter(&motorFeedback);
   DHB1_motorDisable(&pmodDHB1);
}

void EnableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheEnable();
#endif
#endif
}

void DisableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#endif
}

void turnLeft(int steps){
	DHB1_motorDisable(&pmodDHB1);
	usleep(6);
	DHB1_setDirs(&pmodDHB1, 0, 0); // Set direction left
	drive(steps);
	usleep(steps * (float)2000/120);

}

void turnRight(int steps){
	DHB1_motorDisable(&pmodDHB1);
	usleep(6);
	DHB1_setDirs(&pmodDHB1, 1, 1); // Set direction right
	drive(steps);
	usleep(steps * (float)2000/120);

}

void moveForward(int steps){
	DHB1_motorDisable(&pmodDHB1);
	usleep(6);
	DHB1_setDirs(&pmodDHB1, 0, 1); // Set direction forward
	drive(steps);
	usleep(steps * (float)2000/240);
}

void moveBackward(int steps){
	DHB1_motorDisable(&pmodDHB1);
	usleep(6);
	DHB1_setDirs(&pmodDHB1, 1, 0); // Set direction backward
	drive(steps);
	usleep(steps * (float)2000/240);
}