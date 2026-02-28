package service;

import dao.UserDao;
import entity.User;
import jakarta.persistence.EntityManager;

import java.util.List;

public class UserService {

    private final EntityManager em;
    private final UserDao userDao;

    public UserService(EntityManager em) {
        this.em = em;
        this.userDao = new UserDao(em);
    }

    /** Register a new user/vendor. Returns false if email already exists. */
    public boolean register(User user) {
        if (userDao.findByEmail(user.getEmail()) != null) return false;
        em.getTransaction().begin();
        boolean saved = userDao.save(user);
        em.getTransaction().commit();
        return saved;
    }

    /** Login. Returns null on failure. Vendors must be verified. */
    public User login(String email, String password) {
        User user = userDao.findByEmail(email);
        if (user == null || !user.getPassword().equals(password)) return null;
        return user; // caller checks verified flag for vendors
    }

    public User getUserById(int id)          { return userDao.findById(id); }
    public User getUserByEmail(String email) { return userDao.findByEmail(email); }

    public boolean updateUser(User user) {
        em.getTransaction().begin();
        boolean ok = userDao.update(user);
        em.getTransaction().commit();
        return ok;
    }

    public void deleteUser(int userId) {
        User user = userDao.findById(userId);
        if (user != null) {
            em.getTransaction().begin();
            userDao.delete(user);
            em.getTransaction().commit();
        }
    }

    /** Admin: verify a vendor */
    public boolean verifyVendor(int userId) {
        User user = userDao.findById(userId);
        if (user == null || !"vendor".equals(user.getRole())) return false;
        em.getTransaction().begin();
        user.setVerified(true);
        userDao.update(user);
        em.getTransaction().commit();
        return true;
    }

    /** Admin: revoke vendor verification */
    public boolean revokeVendor(int userId) {
        User user = userDao.findById(userId);
        if (user == null || !"vendor".equals(user.getRole())) return false;
        em.getTransaction().begin();
        user.setVerified(false);
        userDao.update(user);
        em.getTransaction().commit();
        return true;
    }

    public List<User> getAllUsers()   { return userDao.findAllUsers(); }
    public List<User> getAllVendors() { return userDao.findAllVendors(); }
    public List<User> getAllMembers() { return userDao.findAll(); }
}
