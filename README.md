# spring mvc
使用spring mvc的配置连接redis实现不同tomcat服务器之间的session共享，对照redis项目com.fei包
具体代码逻辑参考：
<br> RedisHttpSessionConfiguration public RedisOperationsSessionRepository sessionRepository()
<br> SpringHttpSessionConfiguration public <S extends Session> SessionRepositoryFilter<? extends Session> springSessionRepositoryFilter(SessionRepository<S> sessionRepository)
<br> SessionRepositoryFilter

1、在maven项目pom.xml中添加如下依赖
注意：如果不添加commons-fileupload依赖，项目将会报java.lang.NoClassDefFoundError: org/apache/commons/fileupload/FileItemFactory错误


        <dependency>
            <groupId>org.springframework.session</groupId>
            <artifactId>spring-session-data-redis</artifactId>
            <version>1.2.2.RELEASE</version>
            <type>pom</type>
        </dependency>
        <dependency>
            <groupId>commons-fileupload</groupId>
            <artifactId>commons-fileupload</artifactId>
            <version>1.3.1</version>
        </dependency>
        
2、设置redis配置属性(默认你已经安装 redis)
添加redis.properties

    redis.host=192.168.1.1
    redis.port=6379
    redis.pass=mypass
      
      
    redis.maxIdle=300
    redis.maxWaitMillis=1000
    redis.testOnBorrow=true
    redis.database=1
    redis.timeout=3000
    redis.usePool=true
    
3、spring 主配置文件中添加如下

     <bean id="poolConfig" class="redis.clients.jedis.JedisPoolConfig"
              p:maxIdle="${redis.maxIdle}" p:maxWaitMillis="${redis.maxWaitMillis}" p:testOnBorrow="${redis.testOnBorrow}">
        </bean>
    
        <!-- 添加RedisHttpSessionConfiguration用于session共享 -->
        <bean class="org.springframework.session.data.redis.config.annotation.web.http.RedisHttpSessionConfiguration"/>
    
        <bean id="jedisConnectionFactory" class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory"
              p:hostName="${redis.host}" p:port="${redis.port}" p:password="${redis.pass}" p:poolConfig-ref="poolConfig"
              p:usePool="${redis.usePool}"
              p:database="${redis.database}"
              p:timeout="${redis.timeout}"/>
        
4、在web.xml添加filter

      <filter>
        <filter-name>springSessionRepositoryFilter</filter-name>
        <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
      </filter>
      <filter-mapping>
        <filter-name>springSessionRepositoryFilter</filter-name>
        <url-pattern>/*</url-pattern>
      </filter-mapping>

# spring和web容器整合之DelegatingFilterProxy理解

一般的filter是那些实现了javax.servlet.filter接口的实现类，写在web.xml中供web容器加载创建实例使用。
但是如果把所有filter都写在web.xml中让web容器管理可能不是很方便或者有问题，无法获得spring框架提供的bean的管理的便利，
这时通过DelegatingFilterProxy，将它放入web容器中，同时代理一个由spring管理的filter bean，获得Spring的依赖注入机制和生命周期接口，配置轻便且更容器扩展复杂的filter逻辑。
比如spring security的功能实现，就是通过DelegatingFilterProxy代理FilterChainProxy(默认beanName是"springSecurityFilterChain")，
而FilterChainProxy本身连接了web容器管理的originalChain和添加的spring容器管理的执行security逻辑的一系列additionalFilters，达到安全访问功能目的。
具体代码逻辑可参考：WebSecurityConfiguration @Bean(name = AbstractSecurityWebApplicationInitializer.DEFAULT_FILTER_NAME)
<br>            AbstractSecurityWebApplicationInitializer insertSpringSecurityFilterChain(ServletContext servletContext)
<br>            WebSecurity
                


