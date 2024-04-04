//
//  AuthService.swift
//  LiftingApp
//
//  Created by Jensen Li on 3/19/24.
//

import Alamofire
import Foundation
import KeychainAccess

class AuthService {
    
    static var BASE_SERVER_URL = "http://127.0.0.1:3000/";
    
    static func hasAccessToken() -> Bool {
        if Bundle.main.bundleIdentifier == nil {
            return false;
        }
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!);
        if keychain["accessToken"] != nil {
            return true
        }
        return false
    }
    
    static func removeAccessToken() -> Bool {
        if Bundle.main.bundleIdentifier == nil {
            return false;
        }
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!);
        keychain["accessToken"] = nil;
        return true;
    }
    
    static func getAccessToken() -> String? {
        if Bundle.main.bundleIdentifier == nil {
            return nil;
        }
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!);
        return keychain["accessToken"];
    }
    
    static func authenticateLocal(username: String, password: String, completion: @escaping (Bool) -> ()) {
        if Bundle.main.bundleIdentifier == nil || username.isEmpty || password.isEmpty {
            completion(false);
            return;
        }
        AF.request(BASE_SERVER_URL + "/auth/local/login", method: .post, parameters: [
            "email": username,
            "password": password
        ]).responseData { response in
            authenticateCallback(response: response, completion: completion);
        }
    }
    
    static func authenticateGoogle(idToken: String, completion: @escaping (Bool) -> ()) {
        if Bundle.main.bundleIdentifier == nil || idToken.isEmpty {
            completion(false);
            return;
        }
        AF.request(BASE_SERVER_URL + "/auth/google/login", method: .post, parameters: [
            "googleId": idToken
        ]).responseData { response in
            authenticateCallback(response: response, completion: completion);
        }
    }
    
    static func authenticateCallback(response: AFDataResponse<Data>, completion: @escaping (Bool) -> ()) {
        if response.response?.statusCode == 200 {
            switch response.result {
                case .success(let data):
                    do {
                        let asJSON = (try JSONSerialization.jsonObject(with: data)) as? [String: Any]
                        if asJSON == nil || asJSON?["access_token"] == nil {
                            completion(false);
                            return;
                        }
                        let keychain = Keychain(service: Bundle.main.bundleIdentifier!);
                        keychain["accessToken"] = asJSON!["access_token"] as? String;
                        completion(true);
                    } catch {
                        print(error);
                    }
                case .failure(let error):
                    print(error);
                }
        } else {
            completion(false);
        }
    }
}
