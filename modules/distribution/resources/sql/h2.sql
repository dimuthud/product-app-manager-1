CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (
            CONSUMER_KEY VARCHAR (512),
            CONSUMER_SECRET VARCHAR (512),
            USERNAME VARCHAR (255),
            TENANT_ID INTEGER DEFAULT 0,
            APP_NAME VARCHAR (255),
            OAUTH_VERSION VARCHAR (128),
            CALLBACK_URL VARCHAR (1024),
            LOGIN_PAGE_URL VARCHAR (1024),
            ERROR_PAGE_URL VARCHAR (1024),
            CONSENT_PAGE_URL VARCHAR (1024),
            GRANT_TYPES VARCHAR (1024),
            PRIMARY KEY (CONSUMER_KEY)
);

CREATE TABLE IF NOT EXISTS APM_SUBSCRIBER (
    SUBSCRIBER_ID INTEGER AUTO_INCREMENT,
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EMAIL_ADDRESS VARCHAR(256) NULL,
    DATE_SUBSCRIBED TIMESTAMP NOT NULL,
    PRIMARY KEY (SUBSCRIBER_ID),
    UNIQUE (TENANT_ID,USER_ID)
);

CREATE TABLE IF NOT EXISTS APM_APPLICATION (
    APPLICATION_ID INTEGER AUTO_INCREMENT,
    NAME VARCHAR(100),
    SUBSCRIBER_ID INTEGER,
    APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
    CALLBACK_URL VARCHAR(512),
    DESCRIPTION VARCHAR(512),
	APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES APM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID),
    UNIQUE (NAME,SUBSCRIBER_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP (
    APP_ID INTEGER AUTO_INCREMENT,
    APP_PROVIDER VARCHAR(256),
    APP_NAME VARCHAR(256),
    APP_VERSION VARCHAR(30),
    CONTEXT VARCHAR(256),
    TRACKING_CODE varchar(100),
    UUID varchar(500),
    LOG_OUT_URL varchar(500),
    APP_ALLOW_ANONYMOUS BOOLEAN NULL,
    PRIMARY KEY(APP_ID),
    UNIQUE (APP_PROVIDER,APP_NAME,APP_VERSION,TRACKING_CODE,UUID)
);

CREATE TABLE IF NOT EXISTS APM_POLICY_GROUP
( 
	POLICY_GRP_ID INTEGER AUTO_INCREMENT,
	NAME VARCHAR(256),
	AUTH_SCHEME VARCHAR(50) NULL,
	THROTTLING_TIER varchar(512) DEFAULT NULL,
	USER_ROLES varchar(512) DEFAULT NULL,  
	URL_ALLOW_ANONYMOUS BOOLEAN DEFAULT FALSE,
	DESCRIPTION VARCHAR(1000) NULL,   
	PRIMARY KEY (POLICY_GRP_ID)
);
 
CREATE TABLE IF NOT EXISTS APM_POLICY_GROUP_MAPPING
( 
	POLICY_GRP_ID INTEGER  NOT NULL,
	APP_ID INTEGER NOT NULL,
	FOREIGN KEY (APP_ID) REFERENCES  APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID)  ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (POLICY_GRP_ID,APP_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP_URL_MAPPING (
    URL_MAPPING_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR(20) NULL,
	URL_PATTERN VARCHAR(512) NULL, 
    SKIP_THROTTLING BOOLEAN DEFAULT FALSE,  
    POLICY_GRP_ID INTEGER NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP (POLICY_GRP_ID),
    PRIMARY KEY(URL_MAPPING_ID)
);

CREATE TABLE IF NOT EXISTS APM_ENTITLEMENT_POLICY_PARTIAL (
    ENTITLEMENT_POLICY_PARTIAL_ID INTEGER AUTO_INCREMENT,
    NAME varchar(256) DEFAULT NULL,
    CONTENT varchar(2048) DEFAULT NULL,
    SHARED  BOOLEAN DEFAULT FALSE,
    AUTHOR varchar(256) DEFAULT NULL,	
    DESCRIPTION VARCHAR(1000) NULL,
    PRIMARY KEY(ENTITLEMENT_POLICY_PARTIAL_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP_XACML_PARTIAL_MAPPINGS (
    APP_ID INTEGER,
    PARTIAL_ID INTEGER,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY(APP_ID,PARTIAL_ID)
);

CREATE TABLE IF NOT EXISTS APM_POLICY_GRP_PARTIAL_MAPPING (
    POLICY_GRP_ID INTEGER NOT NULL,
    POLICY_PARTIAL_ID INTEGER NOT NULL,
    EFFECT varchar(50),
    POLICY_ID varchar(50) DEFAULT NULL,
    FOREIGN KEY(POLICY_GRP_ID) REFERENCES APM_POLICY_GROUP(POLICY_GRP_ID)  ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(POLICY_PARTIAL_ID) REFERENCES APM_ENTITLEMENT_POLICY_PARTIAL(ENTITLEMENT_POLICY_PARTIAL_ID),
    PRIMARY KEY(POLICY_GRP_ID, POLICY_PARTIAL_ID)
);

CREATE TABLE IF NOT EXISTS APM_SUBSCRIPTION (
    SUBSCRIPTION_ID INTEGER AUTO_INCREMENT,
    SUBSCRIPTION_TYPE VARCHAR(50),
    TIER_ID VARCHAR(50),
    APP_ID INTEGER,
    LAST_ACCESSED TIMESTAMP NULL,
    APPLICATION_ID INTEGER,
    SUB_STATUS VARCHAR(50),
    TRUSTED_IDP VARCHAR(255) NULL,
    SUBSCRIPTION_TIME TIMESTAMP NOT NULL,
    FOREIGN KEY(APPLICATION_ID) REFERENCES APM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (SUBSCRIPTION_ID),
    UNIQUE(APP_ID, APPLICATION_ID,SUBSCRIPTION_TYPE)
);

CREATE TABLE IF NOT EXISTS APM_APP_LC_EVENT (
    EVENT_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER NOT NULL,
    PREVIOUS_STATE VARCHAR(50),
    NEW_STATE VARCHAR(50) NOT NULL,
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EVENT_DATE TIMESTAMP NOT NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (EVENT_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP_COMMENTS (
    COMMENT_ID INTEGER AUTO_INCREMENT,
    COMMENT_TEXT VARCHAR(512),
    COMMENTED_USER VARCHAR(255),
    DATE_COMMENTED TIMESTAMP NOT NULL,
    APP_ID INTEGER NOT NULL,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (COMMENT_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP_RATINGS(
    RATING_ID INTEGER AUTO_INCREMENT,
    APP_ID INTEGER,
    RATING INTEGER,
    SUBSCRIBER_ID INTEGER,
    FOREIGN KEY(APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES APM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (RATING_ID)
);

CREATE TABLE IF NOT EXISTS APM_TIER_PERMISSIONS (
    TIER_PERMISSIONS_ID INTEGER AUTO_INCREMENT,
    TIER VARCHAR(50) NOT NULL,
    PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
    ROLES VARCHAR(512) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY(TIER_PERMISSIONS_ID)
);

CREATE TABLE IF NOT EXISTS APM_WORKFLOWS(
    WF_ID INTEGER AUTO_INCREMENT,
    WF_REFERENCE VARCHAR(255) NOT NULL,
    WF_TYPE VARCHAR(255) NOT NULL,
    WF_STATUS VARCHAR(255) NOT NULL,
    WF_CREATED_TIME TIMESTAMP,
    WF_UPDATED_TIME TIMESTAMP,
    WF_STATUS_DESC VARCHAR(1000),
    TENANT_ID INTEGER,
    TENANT_DOMAIN VARCHAR(255),
    WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL,
    PRIMARY KEY (WF_ID),
    UNIQUE (WF_EXTERNAL_REFERENCE)
);

CREATE TABLE IF NOT EXISTS APM_API_CONSUMER_APPS (
 ID INTEGER AUTO_INCREMENT,
 APP_CONSUMER_KEY VARCHAR(512),
 API_TOKEN_ENDPOINT VARCHAR (1024),
 API_CONSUMER_KEY VARCHAR(512),
 API_CONSUMER_SECRET VARCHAR(512),
 APP_NAME VARCHAR(512),
 PRIMARY KEY (ID, APP_CONSUMER_KEY),
 FOREIGN KEY (APP_CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS APM_APP_HIT_TOTAL (
UUID VARCHAR2(500) NOT NULL,
USER_ID VARCHAR2(50) NOT NULL,
HIT_COUNT BIGINT,
TENANT_ID INTEGER,
PRIMARY KEY (UUID, USER_ID),
FOREIGN KEY (UUID) REFERENCES APM_APP(UUID),
FOREIGN KEY (USER_ID) REFERENCES APM_SUBSCRIBER(USER_ID)
);

CREATE TABLE IF NOT EXISTS APM_APP_JAVA_POLICY
(
JAVA_POLICY_ID INTEGER AUTO_INCREMENT,
DISPLAY_NAME VARCHAR(100) NOT NULL,
FULL_QUALIFI_NAME VARCHAR(256) NOT NULL,
DESCRIPTION VARCHAR(2500),
DISPLAY_ORDER_SEQ_NO INTEGER NOT NULL,
IS_MANDATORY BOOLEAN DEFAULT FALSE,
POLICY_PROPERTIES VARCHAR(512) NULL,
IS_GLOBAL BOOLEAN DEFAULT TRUE,
PRIMARY KEY(JAVA_POLICY_ID),
UNIQUE(FULL_QUALIFI_NAME,DISPLAY_ORDER_SEQ_NO)
);


CREATE TABLE IF NOT EXISTS APM_APP_JAVA_POLICY_MAPPING
(
JAVA_POLICY_ID INTEGER NOT NULL,
APP_ID  INTEGER NOT NULL,
PRIMARY KEY (JAVA_POLICY_ID,APP_ID),
FOREIGN KEY (JAVA_POLICY_ID) REFERENCES APM_APP_JAVA_POLICY(JAVA_POLICY_ID) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (APP_ID) REFERENCES APM_APP(APP_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY, IS_GLOBAL )
SELECT 'Reverse Proxy Handler','org.wso2.carbon.appmgt.gateway.handlers.proxy.ReverseProxyHandler','',1,TRUE,TRUE
WHERE NOT EXISTS (SELECT * FROM APM_APP_JAVA_POLICY WHERE  FULL_QUALIFI_NAME ='org.wso2.carbon.appmgt.gateway.handlers.proxy.ReverseProxyHandler') ;
 
INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
SELECT 'SAML2 Authentication Handler','org.wso2.carbon.appmgt.gateway.handlers.security.saml2.SAML2AuthenticationHandler','',2,TRUE,TRUE
WHERE NOT EXISTS (SELECT * FROM APM_APP_JAVA_POLICY WHERE  FULL_QUALIFI_NAME ='org.wso2.carbon.appmgt.gateway.handlers.security.saml2.SAML2AuthenticationHandler');

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY, POLICY_PROPERTIES,IS_GLOBAL )
SELECT 'API Throttle Handler','org.wso2.carbon.appmgt.gateway.handlers.throttling.APIThrottleHandler','',3,TRUE,'[{"id":"A"},{"policyKey":"gov:/appmgt/applicationdata/tiers.xml"}]',TRUE
WHERE NOT EXISTS (SELECT * FROM APM_APP_JAVA_POLICY WHERE  FULL_QUALIFI_NAME ='org.wso2.carbon.appmgt.gateway.handlers.throttling.APIThrottleHandler');

INSERT INTO APM_APP_JAVA_POLICY(DISPLAY_NAME, FULL_QUALIFI_NAME, DESCRIPTION, DISPLAY_ORDER_SEQ_NO,IS_MANDATORY,IS_GLOBAL)
SELECT 'Publish Statistics:','org.wso2.carbon.appmgt.usage.publisher.APPMgtUsageHandler','',4,FALSE,TRUE
WHERE NOT EXISTS (SELECT * FROM APM_APP_JAVA_POLICY WHERE  FULL_QUALIFI_NAME ='org.wso2.carbon.appmgt.usage.publisher.APPMgtUsageHandler');


 
CREATE INDEX IDX_SUB_APP_ID ON APM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID);
