#include "raylib.h"
#include <stdbool.h>

// Configuration constants
#define SCREEN_WIDTH 800
#define SCREEN_HEIGHT 450
#define TARGET_FPS 60
#define NUM_BALLS 2500
#define BALL_RADIUS 20.0f
#define BALL_MIN_SPEED 2.0f
#define BALL_MAX_SPEED 8.0f
#define UI_TEXT_SIZE 20

// Ball structure
typedef struct
{
    Vector2 position;
    Vector2 velocity;
    float radius;
    Color color;
} Ball;

// Function to update ball position and handle collisions
void UpdateBall(Ball *ball, const int screenWidth, const int screenHeight)
{
    // Update position based on velocity
    ball->position.x += ball->velocity.x;
    ball->position.y += ball->velocity.y;

    // Handle wall collisions
    if (ball->position.x + ball->radius >= screenWidth || ball->position.x - ball->radius <= 0)
        ball->velocity.x *= -1;

    if (ball->position.y + ball->radius >= screenHeight || ball->position.y - ball->radius <= 0)
    {
        ball->velocity.y *= -1;
        // Clamp position inside bounds
        if (ball->position.y + ball->radius >= screenHeight)
            ball->position.y = screenHeight - ball->radius;
        else if (ball->position.y - ball->radius <= 0)
            ball->position.y = ball->radius;
    }
}

// Function to draw ball
void DrawBall(const Ball ball)
{
    DrawCircleV(ball.position, ball.radius, ball.color);
}

int main(void)
{
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Raylib C - Bouncing Ball");
    SetTargetFPS(TARGET_FPS);

    // Initialize balls
    Ball balls[NUM_BALLS];
    Color ballColors[] = {RED, BLUE, GREEN, YELLOW, PURPLE, ORANGE, PINK, GOLD, LIME, MAROON,
                          DARKGREEN, SKYBLUE, DARKBLUE, MAGENTA, DARKBROWN, GRAY, DARKGRAY};
    int numColors = sizeof(ballColors) / sizeof(ballColors[0]);

    for (int i = 0; i < NUM_BALLS; i++)
    {
        balls[i].position.x = (float)GetRandomValue((int)BALL_RADIUS, SCREEN_WIDTH - (int)BALL_RADIUS);
        balls[i].position.y = (float)GetRandomValue((int)BALL_RADIUS, SCREEN_HEIGHT - (int)BALL_RADIUS);

        float speedX = (float)GetRandomValue((int)(BALL_MIN_SPEED * 100), (int)(BALL_MAX_SPEED * 100)) / 100.0f;
        float speedY = (float)GetRandomValue((int)(BALL_MIN_SPEED * 100), (int)(BALL_MAX_SPEED * 100)) / 100.0f;

        if (GetRandomValue(0, 1))
            speedX *= -1;
        if (GetRandomValue(0, 1))
            speedY *= -1;

        balls[i].velocity.x = speedX;
        balls[i].velocity.y = speedY;
        balls[i].radius = BALL_RADIUS;
        balls[i].color = ballColors[GetRandomValue(0, numColors - 1)];
    }

    while (!WindowShouldClose())
    {
        // Update
        for (int i = 0; i < NUM_BALLS; i++)
        {
            UpdateBall(&balls[i], SCREEN_WIDTH, SCREEN_HEIGHT);
        }

        // Draw
        BeginDrawing();
        ClearBackground(RAYWHITE);

        for (int i = 0; i < NUM_BALLS; i++)
        {
            DrawBall(balls[i]);
        }
        DrawText("C Version - Procedural Programming", 10, 10, UI_TEXT_SIZE, DARKGRAY);

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
