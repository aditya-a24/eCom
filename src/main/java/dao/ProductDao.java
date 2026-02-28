package dao;

import entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;

import java.util.List;

public class ProductDao {

    private EntityManager em;

    public ProductDao(EntityManager em) {
        this.em = em;
    }

    // Save new product
    public boolean save(Product product) {
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(product);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        }
        return false;
    }

    // Update existing product
    public boolean update(Product product) {
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(product);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        }
        return false;
    }

    // Delete product
    public boolean delete(Product product) {
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.remove(em.contains(product) ? product : em.merge(product));
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        }
        return false;
    }

    // Find by ID
    public Product findById(int id) {
        return em.find(Product.class, id);
    }

    // Get all products
    public List<Product> findAll() {
        TypedQuery<Product> query = em.createQuery("SELECT p FROM Product p", Product.class);
        return query.getResultList();
    }

    // Get products by vendor email
    public List<Product> findByVendor(String vendorEmail) {
        TypedQuery<Product> query = em.createQuery(
                "SELECT p FROM Product p WHERE p.vendorEmail = :email", Product.class
        );
        query.setParameter("email", vendorEmail);
        return query.getResultList();
    }

    // Get only available products
    public List<Product> findAvailableProducts() {
        TypedQuery<Product> query = em.createQuery(
                "SELECT p FROM Product p WHERE p.status = 'Available'", Product.class
        );
        return query.getResultList();
    }
}