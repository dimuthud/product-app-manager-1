/*
*  Copyright (c) 2016, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
*  WSO2 Inc. licenses this file to you under the Apache License,
*  Version 2.0 (the "License"); you may not use this file except
*  in compliance with the License.
*  You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
* KIND, either express or implied.  See the License for the
* specific language governing permissions and limitations
* under the License.
*/
package org.wso2.JWTSecurity.servlets;

import org.wso2.JSON.JSONObject;
import org.wso2.JSON.parser.JSONParser;
import org.wso2.JSON.parser.ParseException;

import javax.xml.bind.DatatypeConverter;
import java.io.FileInputStream;
import java.security.KeyStore;
import java.security.Signature;
import java.security.cert.Certificate;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Simple JWT processor. This is specially written for JWT generated by WSO2 AppManager.
 */
public class JWTValidator {
    private JSONObject jsonHeaderObject;
    private JSONObject jsonClaimObject;
    private static final Logger log = Logger.getLogger((JWTValidator.class.getName()));

    /**
     * Validate the jwt signature.
     * @param jwtToken jwt token coming from AppManager.
     * @param TRUST_STORE_PATH Path to the key store(jks).
     * @param TRUST_STORE_PASSWORD Key store password.
     * @param ALIAS Alias name(can configured in Tomcat_home/config/context.xml).
     * @return a boolean.
     */
    public boolean isValid(String jwtToken, String TRUST_STORE_PATH, String TRUST_STORE_PASSWORD,
                           String ALIAS) {


        String jwtAssertion = null;
        byte[] jwtSignature = getjwtSignatureDecode(jwtPartitions(jwtToken));
        String jwtHeader = getjwtHeaderDecode(jwtPartitions(jwtToken));
        String jwtPayLoad = getjwtPayloadDecode(jwtPartitions(jwtToken));

        if (jwtHeader != null) {
            jsonHeaderObject = jsonObjectConverter(jwtHeader);
        }
        if (jwtPayLoad != null) {
            jsonClaimObject = jsonObjectConverter(jwtPayLoad);
        }
        if (jwtHeader != null && jwtPayLoad != null) {
            jwtAssertion = jwtPartitions(jwtToken)[0] + "." + jwtPartitions(jwtToken)[1];
        }

        KeyStore keyStore = null;
        String thumbPrint = new String(DatatypeConverter.parseBase64Binary((jsonHeaderObject.get(
                "x5t").toString())));
        String signatureAlgo = (String) jsonHeaderObject.get("alg");

        if ("RS256".equals(signatureAlgo)) {
            signatureAlgo = "SHA256withRSA";
        } else if ("RS515".equals(signatureAlgo)) {
            signatureAlgo = "SHA512withRSA";
        } else if ("RS384".equals(signatureAlgo)) {
            signatureAlgo = "SHA384withRSA";
        } else {
            // by default
            signatureAlgo = "SHA256withRSA";
        }

        if (jwtAssertion != null && jwtSignature != null) {

            try {
                keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
                keyStore.load(new FileInputStream(TRUST_STORE_PATH),
                              TRUST_STORE_PASSWORD.toCharArray());
                Certificate certificate = keyStore.getCertificate(ALIAS);
                Signature signature = Signature.getInstance(signatureAlgo);
                signature.initVerify(certificate);
                signature.update(jwtAssertion.getBytes());
                return signature.verify(jwtSignature);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            System.err.println("Signature is null");
        }
        return false;
    }

    /**
     * Returns a string of the payload part of the jwt token.
     * @param jwtArray jwt token splitted by "//."
     * @return payLoad.
     */
    public String getjwtPayloadDecode(String[] jwtArray) {
        if (jwtArray != null) {
            byte[] decodedPayload = DatatypeConverter.parseBase64Binary(jwtArray[1]);
            String payloadString = new String(decodedPayload);
            return payloadString;
        }
        return null;
    }

    /**
     * Returns a string of the header part of the jwt token.
     * @param jwtArray wt token splitted by "//."
     * @return header.
     */
    public String getjwtHeaderDecode(String[] jwtArray) {
        if (jwtArray != null) {
            byte[] decodedHeader = DatatypeConverter.parseBase64Binary(jwtArray[0]);
            String HeaderString = new String(decodedHeader);
            return HeaderString;
        }
        return null;
    }

    /**
     * Decode the signature part of the jwt token.
     * @param jwtArray jwt token splitted by "//."
     * @return signature as a bite array.
     */
    private byte[] getjwtSignatureDecode(String[] jwtArray) {
        if (jwtArray != null) {
            byte[] decodedSignature = DatatypeConverter.parseBase64Binary(jwtArray[2]);
            return decodedSignature;
        }
        return null;
    }

    /**
     * Split jwt token from full stop.
     * @param jwtHeader Complete jwt token.
     * @return Array.
     */
    public String[] jwtPartitions(String jwtHeader) {
        String[] jwtArray = jwtHeader.split("\\.");
        if (jwtArray.length != 3) {
            return null;
        }
        return jwtArray;
    }

    /**
     * Convert a given formatted string in to a JSON object.
     * @param payloadString Formatted String.
     * @return a JSON object.
     */
    public JSONObject jsonObjectConverter(String payloadString) {
        JSONObject payLoad = null;
        try {
            payLoad = (JSONObject) new JSONParser().parse(payloadString);
        } catch (ParseException e) {
            log.log(Level.SEVERE, "Error while creating JASON object from payloadString", e);

        }
        return payLoad;
    }
}
