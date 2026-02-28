package service;

import dao.ProductDao;
import entity.Product;
import jakarta.persistence.EntityManager;

import java.util.List;

public class ProductService {

    private final ProductDao productDao;

    public ProductService(EntityManager em) {
        this.productDao = new ProductDao(em);
    }

    /**
     * Add product. Stock drives status automatically via Product.setStock().
     */
    public boolean addProduct(Product product) {
        // Trigger auto-status via setStock
        product.setStock(product.getStock());
        return productDao.save(product);
    }

    /** Update product details (name, price, description). */
    public boolean updateProduct(Product product) {
        return productDao.update(product);
    }

    /**
     * Update stock for a product. Status is automatically updated by entity.
     * Returns false if product not found.
     */
    public boolean updateStock(int productId, int newStock) {
        Product product = productDao.findById(productId);
        if (product == null) return false;
        product.setStock(newStock); // triggers auto-status
        return productDao.update(product);
    }

    /**
     * Delete a product.
     * - Vendor: only if OutOfStock
     * - Admin: always allowed (force=true)
     */
    public boolean deleteProduct(Product product, boolean force) {
        if (!force && !"OutOfStock".equals(product.getStatus())) return false;
        return productDao.delete(product);
    }

    /** Backward-compat overload used by vendor (force=false) */
    public boolean deleteProduct(Product product) {
        return deleteProduct(product, false);
    }

    public Product      getProductById(int id)          { return productDao.findById(id); }
    public List<Product> getAllProducts()                { return productDao.findAll(); }
    public List<Product> getProductsByVendor(String v)  { return productDao.findByVendor(v); }
    public List<Product> getAvailableProducts()         { return productDao.findAvailableProducts(); }
}
