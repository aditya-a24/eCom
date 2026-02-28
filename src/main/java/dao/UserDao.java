package dao;

import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import java.util.List;

public class UserDao {

    private final EntityManager em;

    public UserDao(EntityManager em) { this.em = em; }

    public boolean save(User user) {
        em.persist(user);
        return true;
    }

    public User findByEmail(String email) {
        return em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                 .setParameter("email", email)
                 .getResultStream().findFirst().orElse(null);
    }

    public User findById(int id) {
        return em.find(User.class, id);
    }

    public boolean update(User user) {
        em.merge(user);
        return true;
    }

    public boolean delete(User user) {
        em.remove(em.contains(user) ? user : em.merge(user));
        return true;
    }

    /** All users with role = "user" */
    public List<User> findAllUsers() {
        return em.createQuery("SELECT u FROM User u WHERE u.role = 'user'", User.class)
                 .getResultList();
    }

    /** All users with role = "vendor" */
    public List<User> findAllVendors() {
        return em.createQuery("SELECT u FROM User u WHERE u.role = 'vendor'", User.class)
                 .getResultList();
    }

    /** All users regardless of role (admin use) */
    public List<User> findAll() {
        return em.createQuery("SELECT u FROM User u", User.class).getResultList();
    }
}
