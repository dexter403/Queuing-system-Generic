#############################################################
# Build                                                     #
#############################################################

FROM node:20.15.0 as build
RUN npm install -g npm@10.7.0

ARG SERVICE
ENV PATH /src/services/$SERVICE/node_modules/.bin:$PATH

# Build @GenericAppvrx-data/generic-repository
WORKDIR /src/modules/data/generic-repository
COPY ./modules/data/generic-repository .
RUN npm i --force
RUN npm run build

# Build @GenericAppvrx/shared-types
WORKDIR /src/shared/shared-types
COPY ./shared/shared-types .
RUN npm i --force
RUN npm run build

# Build @GenericAppvrx/micro-service-communicator
WORKDIR /src/modules/library/micro-service-communicator
COPY ./modules/library/micro-service-communicator .
RUN npm i --force
RUN npm run build

# Build @GenericAppvrx/shared-utilities
WORKDIR /src/modules/library/shared-utilities
COPY ./modules/library/shared-utilities .
RUN npm i --force
RUN npm run build

# Build @GenericAppvrx/micro-service-ruleprocessor
WORKDIR /src/modules/library/micro-service-rulesprocessor
COPY ./modules/library/micro-service-rulesprocessor .
RUN npm i --force
RUN npm run build

# Build $SERVICE
WORKDIR /src/services/$SERVICE
COPY ./services/$SERVICE .
RUN npm i --force
RUN npm run build

#############################################################
# Serve                                                     #
#############################################################

FROM node:20.15.0 as serve
RUN npm install -g npm@10.7.0

ARG SERVICE
ENV NODE_ENV=production
ENV PATH /app/services/$SERVICE/node_modules/.bin:$PATH

# Copy @GenericAppvrx/shared-types build
WORKDIR /app/shared/shared-types
COPY --from=build /src/shared/shared-types/node_modules ./node_modules
COPY --from=build /src/shared/shared-types/package*.json ./
COPY --from=build /src/shared/shared-types/dist ./dist

# Copy @GenericAppvrx-data/generic-repository build
WORKDIR /app/modules/data/generic-repository
COPY --from=build /src/modules/data/generic-repository/node_modules ./node_modules
COPY --from=build /src/modules/data/generic-repository/package*.json ./
COPY --from=build /src/modules/data/generic-repository/dist ./dist

# Copy @GenericAppvrx/micro-service-communicator build
WORKDIR /app/modules/library/micro-service-communicator
COPY --from=build /src/modules/library/micro-service-communicator/node_modules ./node_modules
COPY --from=build /src/modules/library/micro-service-communicator/package*.json ./
COPY --from=build /src/modules/library/micro-service-communicator/dist ./dist

# Copy @GenericAppvrx/shared-utilities build
WORKDIR /app/modules/library/shared-utilities
COPY --from=build /src/modules/library/shared-utilities/node_modules ./node_modules
COPY --from=build /src/modules/library/shared-utilities/package*.json ./
COPY --from=build /src/modules/library/shared-utilities/dist ./dist

# Copy @GenericAppvrx/micro-service-ruleprocessor build
WORKDIR /app/modules/library/micro-service-rulesprocessor
COPY --from=build /src/modules/library/micro-service-rulesprocessor/node_modules ./node_modules
COPY --from=build /src/modules/library/micro-service-rulesprocessor/package*.json ./
COPY --from=build /src/modules/library/micro-service-rulesprocessor/dist ./dist

# Copy $SERVICE build
WORKDIR /app/services/$SERVICE
COPY --from=build /src/services/$SERVICE/node_modules ./node_modules
COPY --from=build /src/services/$SERVICE/package*.json ./
COPY --from=build /src/services/$SERVICE/dist ./dist

# Run
WORKDIR /app/services/$SERVICE
CMD ["npm", "run", "start:prod"]

