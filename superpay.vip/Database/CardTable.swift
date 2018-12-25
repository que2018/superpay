
import SQLite

class CardTable {
    //get connection
    static private func getDatabase() -> Connection? {
        var database: Connection?
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            database = try Connection(fileUrl.path)
        } catch {
            print(error)
        }
        
        return database
    }
    
    //create table
    static func createTable() {
        do {
            let database = getDatabase()!
            let statement = try database.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='card';")
            
            var count = 0
            
            for row in statement {
                count = (count + 1)
            }
            
            if count == 0 {
                let card = Table("card")
                let local_id = Expression<Int64>("local_id")
                let card_number = Expression<String?>("card_number")
                let hashed_number = Expression<String>("hashed_number")
                
                try database.run(card.create { t in
                    t.column(local_id, primaryKey: .autoincrement)
                    t.column(card_number, unique: true)
                    t.column(hashed_number, unique: true)
                })
            }
        } catch {
            print(error)
        }
    }
    
    //add card
    static func addCard(card: Card) -> Int64? {
        let database = getDatabase()!
        let cardTable = Table("card")
        var localId: Int64?
        
        let card_number = Expression<String>("card_number")
        let hashed_number = Expression<String>("hashed_number")
        
        do {
            let insert = cardTable.insert(card_number <- card.cardNumber, hashed_number <- card.hashedNumber)
            localId = try database.run(insert)
        } catch {
            print(error)
        }
        
        return localId
    }
    
    //edit card
    static func editCard(card: Card) -> Bool {
        let database = getDatabase()!
        let cardTable = Table("card")
        
        let local_id = Expression<Int64>("local_id")
        let card_number = Expression<String>("card_number")
        let hashed_number = Expression<String>("hashed_number")
        
        var success = true
        
        do {
            let cardRow = cardTable.filter(local_id == card.localId)
            try database.run(cardRow.update(card_number <- card.cardNumber, hashed_number <- card.hashedNumber))
        } catch {
            success = false
        }
        
        return success
    }
    
    //delete card
    static func deleteCard(card: Card) -> Bool {
        let database = getDatabase()!
        let cardTable = Table("card")
        
        let local_id = Expression<Int64>("local_id")

        var success = true
        
        do {
            let cardRow = cardTable.filter(local_id == card.localId)
            try database.run(cardRow.delete())
        } catch {
            success = false
        }
        
        return success
    }
    
    //get all cards
    static func getCards() -> Array<Card> {
        let database = getDatabase()!
        let cardTable = Table("card")
    
        let local_id = Expression<Int64>("local_id")
        let card_number = Expression<String>("card_number")
        let hashed_number = Expression<String>("hashed_number")
        
        var cards = [Card]()
        
        do {
            for cardRow in try database.prepare(cardTable) {
                let card = Card()
                card.localId = cardRow[local_id]
                card.cardNumber = cardRow[card_number]
                card.hashedNumber = cardRow[hashed_number]
                cards.append(card)
            }
        } catch {
            print(error)
        }
    
        return cards
    }
}
