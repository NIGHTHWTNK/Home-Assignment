import Foundation

struct cartItem: Codable {
	let name: String
	let category: String
	let price: Int
	let amount: Int
}

enum DiscountType {
	case fixedAmount(Double)
	case percentage(Double)
	case categoryPercentage(String, Double)
	case points(Double)
	case seasonal(every: Double,discount: Double)
}


func decodeJSON(_ cartJSON: String) -> [cartItem] {
	guard let sources = Bundle.main.url(forResource: cartJSON, withExtension: "json") else {
		fatalError("Could not find \(cartJSON).json")
	}

	guard let cartData = try? Data(contentsOf: sources) else {
		fatalError("Could not conver data")
	}

	guard let cartItems = try? JSONDecoder().decode([cartItem].self, from: cartData) else {
		fatalError("Failed to decode JSON")
	}
	
	return cartItems
}

func calculate(cart: [cartItem], discountType: DiscountType) -> Double {

	var totalPrice: Double = Double(cart.reduce(0) { $0 + ($1.price * $1.amount) })
	
	switch discountType {
	case .fixedAmount(let Amount):
		totalPrice -= Amount
		
	case .percentage(let percentage):
		totalPrice -= totalPrice * (percentage / 100)
		
	case .categoryPercentage(let category, let percentage):
		let categoryTotal: Double = Double(cart.filter { $0.category == category }.reduce(0) { $0 + ($1.price * $1.amount) })
		totalPrice -= categoryTotal * (percentage / 100)
		
	case .points(let point):
		let maxDiscount = totalPrice * 0.2 // 20% price
		if point <= maxDiscount {
			totalPrice -= point
		}
		
	case .seasonal(let every, let discount):
		totalPrice -= Double(Int(totalPrice / every)) * discount
		
	}
	
	return totalPrice
}


let cartItem1 = decodeJSON("cartItem1")
calculate(cart: cartItem1, discountType: .fixedAmount(50))
calculate(cart: cartItem1, discountType: .percentage(10))

let cartItem2 = decodeJSON("cartItem2")
calculate(cart: cartItem2, discountType: .categoryPercentage("Clothing", 15))

let cartItem3 = decodeJSON("cartItem3")
calculate(cart: cartItem3, discountType: .points(68))
calculate(cart: cartItem3, discountType: .seasonal(every: 300, discount: 40))

