package entity;

import jakarta.persistence.*;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

@Entity
@Table(name = "products")
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private double price;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private String status; // "Available" or "OutOfStock"

    @Column(nullable = false)
    private String vendorEmail;

    /** Stock quantity. 0 → status auto-set to OutOfStock. */
    @Column(nullable = false)
    private int stock = 0;

    /** Comma-separated image URLs (first is the primary/main image). */
    @Column(length = 2000)
    private String imageUrls;

    /** Product category (e.g. Electronics, Fashion, Home, Beauty, Gaming, Books, Sports, Toys). */
    @Column(length = 100)
    private String category;

    public Product() {}

    public Product(String name, double price, String description,
                   String status, String vendorEmail, int stock) {
        this.name = name;
        this.price = price;
        this.description = description;
        this.vendorEmail = vendorEmail;
        this.stock = stock;
        this.status = (stock <= 0) ? "OutOfStock" : status;
    }

    // Getters and Setters
    public int getId()           { return id; }
    public void setId(int id)    { this.id = id; }

    public String getName()          { return name; }
    public void setName(String name) { this.name = name; }

    public double getPrice()            { return price; }
    public void setPrice(double price)  { this.price = price; }

    public String getDescription()                 { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus()            { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getVendorEmail()                  { return vendorEmail; }
    public void setVendorEmail(String vendorEmail)  { this.vendorEmail = vendorEmail; }

    public int getStock()            { return stock; }

    /**
     * Set stock and auto-update status:
     *  stock <= 0  → "OutOfStock"
     *  stock  > 0  → "Available"
     */
    public void setStock(int stock) {
        this.stock = Math.max(0, stock);
        this.status = (this.stock == 0) ? "OutOfStock" : "Available";
    }

    public String getImageUrls() { return imageUrls; }
    public void setImageUrls(String imageUrls) { this.imageUrls = imageUrls; }

    public String getCategory()                { return category; }
    public void setCategory(String category)   { this.category = category; }

    /**
     * Returns the primary (first) image URL, or null if none.
     */
    public String getPrimaryImage() {
        if (imageUrls == null || imageUrls.isBlank()) return null;
        String[] parts = imageUrls.split(",");
        return parts[0].trim().isEmpty() ? null : parts[0].trim();
    }

    /**
     * Returns array of all image URLs. Never null.
     */
    public String[] getAllImages() {
        if (imageUrls == null || imageUrls.isBlank()) return new String[0];
        return imageUrls.split(",");
    }
}
