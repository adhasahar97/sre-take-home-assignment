## FeedMe SRE Engineer Take-Home Assignment
Below is a take-home assignment before the interview for the position. You are required to
1. Understand the situation and use case. You may contact the interviewer for further clarification.
2. Develop and run your deployment plan for Environment, FE, BE using your most efficient tools.
3. Monitor the deployments, simulate some usage on frontend, document and analyze the result.
4. Bring your deployment and result to the next interview session.

### Situation
McDonald is transforming their business during COVID-19. They wanted to build an online order system to tackle with current challenge. As one of the devops engineer in the project, your task is to deploy the prototype that completed by the development team and make it available to the internet for McDonald.

Below is the information given by the development team

### Global environment requirement
- start a mongodb instance, reachable for backend

### Starting the backend
- required nodejs 14
- set environment variable `MONGODB_URL="<mongodb connection url>"`, where `<mongodb connection url>` must match the [official mongodb node driver uri](https://docs.mongodb.com/drivers/node/current/fundamentals/connection/#connection-uri)
- navigate to backend directory `cd backend`
- build using npm `npm install`
- start using node `node index.js`

### Starting the frontend
- navigate to frontend directory `cd frontend`
- modify the variable `backendUrl` to the actual backend endpoint
- serve the http server root from `frontend/`

### Free Resource
You may use the following free resource for the deployment
- https://www.mongodb.com/
- https://www.netlify.com/
- https://vercel.com/

### Mandatory Requirements
Your deployment must meet the following criteria:
- A working FE which reachable through internet
- Monitoring and recovery for different resource
- Documentation for the deployment plan

### Evaluation Criterias

You will be evaluated based a few criterias. The first one is the completion of the **Mandatory Requirements**.

Other than that, please also draft a plan for the following circumstances (this part doesn't need to be implemented, just a draft plan is enough):
- on-demand scaling of the resources
- keeping the application secure and resilient against cyberattacks
- recommended SLOs and SLIs for the service

### Tips on completing this assignment
- Use the best tools you have on hand.
- Try to scope your working hour within 3 hours (1 hour per day if you really busy) and avoid unnecessary optimization and documentation.
- Communicate effectively like you are going to communicate with the actual team member.
