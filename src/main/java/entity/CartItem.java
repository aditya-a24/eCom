package entity;

import jakarta.persistence.*;

/**
 * Represents one line item in a user's cart.
 * Keyed by (userEmail, productId) — upsert-style.
 */
@Entity
@Table(name = "cart_items",
       uniqueConstraints = @UniqueConstraint(columnNames = {"userEmail", "productId"}))
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String userEmail;

    @Column(nullable = false)
    private int productId;

    @Column(nullable = false)
    private int quantity;

    public CartItem() {}

    public CartItem(String userEmail, int productId, int quantity) {
        this.userEmail = userEmail;
        this.productId = productId;
        this.quantity  = quantity;
    }

    public int    getId()               { return id; }
    public void   setId(int id)         { this.id = id; }

    public String getUserEmail()                  { return userEmail; }
    public void   setUserEmail(String userEmail)  { this.userEmail = userEmail; }

    public int    getProductId()              { return productId; }
    public void   setProductId(int productId) { this.productId = productId; }

    public int    getQuantity()             { return quantity; }
    public void   setQuantity(int quantity) { this.quantity = quantity; }
}
