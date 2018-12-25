
import Foundation

class Auth {
    //encode type
    enum CryptoAlgorithm {
        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
        
        var HMACAlgorithm: CCHmacAlgorithm {
            var result: Int = 0
            switch self {
            case .MD5:      result = kCCHmacAlgMD5
            case .SHA1:     result = kCCHmacAlgSHA1
            case .SHA224:   result = kCCHmacAlgSHA224
            case .SHA256:   result = kCCHmacAlgSHA256
            case .SHA384:   result = kCCHmacAlgSHA384
            case .SHA512:   result = kCCHmacAlgSHA512
            }
            return CCHmacAlgorithm(result)
        }
        
        var digestLength: Int {
            var result: Int32 = 0
            switch self {
            case .MD5:      result = CC_MD5_DIGEST_LENGTH
            case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
            }
            
            return Int(result)
        }
    }
    
    //get public header
    static func getPublicAuthHeaders(method: String, apiName: String, parameterString: String)-> [String: String] {
        let requestTime = String(Int64((NSDate().timeIntervalSince1970)))
        
        var authString = parameterString
        
        authString += method + ":"
        authString += apiName + ":"
        authString += requestTime + ":"
        authString += CONSTANT.PUBLIC_KEY + ":"
        
        //print(authString)
        
        let auth = createHaashedCode(string: authString)
        
        let headers = [
            "Auth": auth,
            "Request": requestTime
        ]
        
        return headers
    }
    
    //get private header
    static func getPrivateAuthHeaders(method: String, apiName: String, parameterString: String)-> [String: String] {
        let requestTime = String(Int64((NSDate().timeIntervalSince1970)))
        
        var authString = parameterString
        
        authString += method + ":"
        authString += apiName + ":"
        authString += requestTime + ":"
        authString += UserDefaults.standard.string(forKey: "auth_key")! + ":"
        
        print(authString)
        
        let auth = createHaashedCode(string: authString)
        
        let headers = [
            "Auth": auth,
            "Request": requestTime,
            "User":  UserDefaults.standard.string(forKey: "id")!
        ]
        
        return headers
    }
    
    //create hashcode
    static func createHaashedCode(string: String) -> String {
        let hmacBytes = hmac(algorithm: Auth.CryptoAlgorithm.SHA256, string: string, key: CONSTANT.PUBLIC_KEY)
        let data = NSData(bytes: hmacBytes, length: hmacBytes.count)
        let base64String = data.base64EncodedString()
        return base64String
    }
    
    //hmac encoding
    static func hmac(algorithm: CryptoAlgorithm, string: String, key: String) -> [UInt8] {
        let str = string.cString(using: String.Encoding.utf8)
        let strLen = Int(string.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        return bytesFromResult(result: result, length: digestLen)
    }
    
    //convert char array to bytes
    static func bytesFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> [UInt8] {
        var resultBytes:[UInt8] = []
        
        for i in 0..<length {
            resultBytes.append(result[i])
        }
        
        return resultBytes
    }
}

