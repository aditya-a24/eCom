package dao;

import entity.CartItem;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import java.util.List;

public class CartDao {

    private final EntityManager em;

    public CartDao(EntityManager em) { this.em = em; }

    /** Find existing cart item for this user + product */
    public CartItem findByUserAndProduct(String userEmail, int productId) {
        return em.createQuery(
                "SELECT c FROM CartItem c WHERE c.userEmail = :email AND c.productId = :pid",
                CartItem.class)
                 .setParameter("email", userEmail)
                 .setParameter("pid", productId)
                 .getResultStream().findFirst().orElse(null);
    }

    /** All items in a user's cart */
    public List<CartItem> findByUser(String userEmail) {
        return em.createQuery(
                "SELECT c FROM CartItem c WHERE c.userEmail = :email",
                CartItem.class)
                 .setParameter("email", userEmail)
                 .getResultList();
    }

    public boolean save(CartItem item) {
        em.persist(item);
        return true;
    }

    public boolean update(CartItem item) {
        em.merge(item);
        return true;
    }

    public boolean delete(CartItem item) {
        em.remove(em.contains(item) ? item : em.merge(item));
        return true;
    }

    public boolean deleteAllByUser(String userEmail) {
        em.createQuery("DELETE FROM CartItem c WHERE c.userEmail = :email")
          .setParameter("email", userEmail)
          .executeUpdate();
        return true;
    }
}
