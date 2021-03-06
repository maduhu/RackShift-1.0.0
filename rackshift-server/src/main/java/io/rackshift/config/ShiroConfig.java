package io.rackshift.config;

import io.rackshift.security.LoginFilter;
import io.rackshift.security.ShiroDBRealm;
import org.apache.shiro.cache.MemoryConstrainedCacheManager;
import org.apache.shiro.session.mgt.SessionManager;
import org.apache.shiro.spring.LifecycleBeanPostProcessor;
import org.apache.shiro.spring.security.interceptor.AuthorizationAttributeSourceAdvisor;
import org.apache.shiro.spring.web.ShiroFilterFactoryBean;
import org.apache.shiro.web.mgt.DefaultWebSecurityManager;
import org.apache.shiro.web.servlet.SimpleCookie;
import org.apache.shiro.web.session.mgt.DefaultWebSessionManager;
import org.springframework.aop.framework.autoproxy.DefaultAdvisorAutoProxyCreator;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;

import javax.servlet.DispatcherType;
import javax.servlet.Filter;
import java.util.EnumSet;
import java.util.Map;
import java.util.Objects;

@Configuration
public class ShiroConfig {

    @Bean
    public ShiroFilterFactoryBean getShiroFilterFactoryBean(DefaultWebSecurityManager sessionManager) {
        ShiroFilterFactoryBean shiroFilterFactoryBean = new ShiroFilterFactoryBean();
        shiroFilterFactoryBean.getFilters().put("authc", new LoginFilter());
        shiroFilterFactoryBean.setLoginUrl("/login");
        shiroFilterFactoryBean.setSecurityManager(sessionManager);
        shiroFilterFactoryBean.setUnauthorizedUrl("/403");
        shiroFilterFactoryBean.setSuccessUrl("/");


        Map<String, String> filterChainDefinitionMap = shiroFilterFactoryBean.getFilterChainDefinitionMap();
        filterChainDefinitionMap.put("/resource/**", "anon");
        filterChainDefinitionMap.put("/", "anon");
        filterChainDefinitionMap.put("/signin", "anon");
        filterChainDefinitionMap.put("/isLogin", "anon");
        filterChainDefinitionMap.put("/css/**", "anon");
        filterChainDefinitionMap.put("/js/**", "anon");
        filterChainDefinitionMap.put("/img/**", "anon");
        filterChainDefinitionMap.put("/fonts/**", "anon");

        filterChainDefinitionMap.put("/api/**", "anon");
        filterChainDefinitionMap.put("/403", "anon");
        filterChainDefinitionMap.put("/hello", "anon");
        filterChainDefinitionMap.put("/anonymous/**", "anon");
        filterChainDefinitionMap.put("/**", "authc");
        filterChainDefinitionMap.put("/rs-websocket", "anon");
        filterChainDefinitionMap.put("/refresh", "anon");
        return shiroFilterFactoryBean;
    }

    @Bean(name = "shiroFilter")
    public FilterRegistrationBean<Filter> shiroFilter(ShiroFilterFactoryBean shiroFilterFactoryBean) throws Exception {
        FilterRegistrationBean<Filter> registration = new FilterRegistrationBean<>();
        registration.setFilter((Filter) Objects.requireNonNull(shiroFilterFactoryBean.getObject()));
        registration.setDispatcherTypes(EnumSet.allOf(DispatcherType.class));
        return registration;
    }

    @Bean
    public MemoryConstrainedCacheManager memoryConstrainedCacheManager() {
        return new MemoryConstrainedCacheManager();
    }

    /**
     * securityManager ??????????????????shiroDBRealm??????????????????????????????
     * ??????????????? handleContextRefresh
     * http://www.debugrun.com/a/NKS9EJQ.html
     */
    @Bean(name = "securityManager")
    public DefaultWebSecurityManager securityManager(SessionManager sessionManager, MemoryConstrainedCacheManager memoryConstrainedCacheManager) {
        DefaultWebSecurityManager dwsm = new DefaultWebSecurityManager();
        dwsm.setSessionManager(sessionManager);
        dwsm.setCacheManager(memoryConstrainedCacheManager);
        return dwsm;
    }

    @Bean(name = "shiroDBRealm")
    @DependsOn("lifecycleBeanPostProcessor")
    public ShiroDBRealm getShiroDBRealm() {
        return new ShiroDBRealm();
    }

    @Bean(name = "lifecycleBeanPostProcessor")
    public LifecycleBeanPostProcessor lifecycleBeanPostProcessor() {
        return new LifecycleBeanPostProcessor();
    }

    @Bean
    public DefaultAdvisorAutoProxyCreator getDefaultAdvisorAutoProxyCreator() {
        DefaultAdvisorAutoProxyCreator daap = new DefaultAdvisorAutoProxyCreator();
        daap.setProxyTargetClass(true);
        return daap;
    }

    @Bean
    public AuthorizationAttributeSourceAdvisor getAuthorizationAttributeSourceAdvisor(DefaultWebSecurityManager sessionManager) {
        AuthorizationAttributeSourceAdvisor aasa = new AuthorizationAttributeSourceAdvisor();
        aasa.setSecurityManager(sessionManager);
        return new AuthorizationAttributeSourceAdvisor();
    }

    @Bean
    public SessionManager sessionManager(MemoryConstrainedCacheManager memoryConstrainedCacheManager) {
        DefaultWebSessionManager sessionManager = new DefaultWebSessionManager();
        sessionManager.setSessionIdUrlRewritingEnabled(false);
        sessionManager.setGlobalSessionTimeout(3600000L);
        sessionManager.setDeleteInvalidSessions(true);
        sessionManager.setSessionValidationSchedulerEnabled(true);
        SimpleCookie sessionIdCookie = new SimpleCookie();
        sessionManager.setSessionIdCookie(sessionIdCookie);
        sessionIdCookie.setPath("/");
        sessionIdCookie.setName("RS_SESSION_ID");
        sessionManager.setCacheManager(memoryConstrainedCacheManager);
        return sessionManager;
    }

    /**
     * ??????ApplicationContext ?????????????????? ??????shiroRealm
     */
    @EventListener
    public void handleContextRefresh(ContextRefreshedEvent event) {
        ApplicationContext context = event.getApplicationContext();
        ShiroDBRealm shiroDBRealm = (ShiroDBRealm) context.getBean("shiroDBRealm");
        ((DefaultWebSecurityManager) context.getBean("securityManager")).setRealm(shiroDBRealm);
    }
}
