package service;

import dao.CartDao;
import dao.ProductDao;
import entity.CartItem;
import entity.Product;
import jakarta.persistence.EntityManager;

import java.util.List;

public class CartService {

    private final EntityManager em;
    private final CartDao cartDao;
    private final ProductDao productDao;

    public CartService(EntityManager em) {
        this.em = em;
        this.cartDao = new CartDao(em);
        this.productDao = new ProductDao(em);
    }

    /**
     * Add one unit of a product to the user's cart.
     * If the item already exists, increments quantity.
     * Returns false if product unavailable or out of stock.
     */
    public boolean addToCart(String userEmail, int productId) {
        Product p = productDao.findById(productId);
        if (p == null || !"Available".equals(p.getStatus()) || p.getStock() <= 0) return false;

        em.getTransaction().begin();
        CartItem existing = cartDao.findByUserAndProduct(userEmail, productId);
        if (existing != null) {
            existing.setQuantity(existing.getQuantity() + 1);
            cartDao.update(existing);
        } else {
            cartDao.save(new CartItem(userEmail, productId, 1));
        }
        em.getTransaction().commit();
        return true;
    }

    /**
     * Remove one item (by productId) from the cart.
     */
    public boolean removeFromCart(String userEmail, int productId) {
        CartItem item = cartDao.findByUserAndProduct(userEmail, productId);
        if (item == null) return false;
        em.getTransaction().begin();
        cartDao.delete(item);
        em.getTransaction().commit();
        return true;
    }

    /** Get all cart items for a user. */
    public List<CartItem> getCartItems(String userEmail) {
        return cartDao.findByUser(userEmail);
    }

    /** Clear the entire cart for a user. */
    public void clearCart(String userEmail) {
        em.getTransaction().begin();
        cartDao.deleteAllByUser(userEmail);
        em.getTransaction().commit();
    }
}
