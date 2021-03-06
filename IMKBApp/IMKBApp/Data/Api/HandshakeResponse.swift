//
//  HandshakeResponse.swift
//  IMKBApp
//
//  Created by MacOS on 16.11.2021.
//

import Foundation
import CryptoSwift

struct HandshakeResponse: Codable {
    var aesKey: String?
    var aesIV: String?
    var authorization: String?
    var lifeTime: String?
    var status: Status?

    enum CodingKeys: String, CodingKey {

        case aesKey = "aesKey"
        case aesIV = "aesIV"
        case authorization = "authorization"
        case lifeTime = "lifeTime"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        aesKey = try values.decodeIfPresent(String.self, forKey: .aesKey)
        aesIV = try values.decodeIfPresent(String.self, forKey: .aesIV)
        authorization = try values.decodeIfPresent(String.self, forKey: .authorization)
        lifeTime = try values.decodeIfPresent(String.self, forKey: .lifeTime)
        status = try values.decodeIfPresent(Status.self, forKey: .status)
    }
    
    func getPeriodParameter(periodTag: String) -> String {
        let intKey = [UInt8](base64: aesKey!)
        let intIV = [UInt8](base64: aesIV!)
        let aes = try? AES(key: intKey, blockMode: CBC(iv: intIV), padding: .pkcs7)
        let encryptPeriod = try? aes?.encrypt(Array(periodTag.utf8))
        return (encryptPeriod?.toBase64())!
    }
    
    func getStockId(id: Int) -> String {
        let intKey = [UInt8](base64: aesKey!)
        let intIV = [UInt8](base64: aesIV!)
        let aes = try? AES(key: intKey, blockMode: CBC(iv: intIV), padding: .pkcs7)
        let encryptId = try? aes?.encrypt(Array(String(id).utf8))
        return (encryptId?.toBase64())!
    }
    
    func getSymbol(symbol: String) -> String {
        let intKey = [UInt8](base64: aesKey!)
        let intIV = [UInt8](base64: aesIV!)
        let intSymbol = [UInt8](base64: symbol)
        let aes = try? AES(key: intKey, blockMode: CBC(iv: intIV), padding: .pkcs7)
        let decryptSymbol = try? aes?.decrypt(intSymbol)
        let strSymbol = String(bytes: decryptSymbol!, encoding: String.Encoding.utf8)
        return strSymbol!
    }
}
