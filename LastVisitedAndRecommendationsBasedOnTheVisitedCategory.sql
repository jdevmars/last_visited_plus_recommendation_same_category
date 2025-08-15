/*

	SQL templates to obtain the last visited product, and also to recommend up to 6 products of the category of the last visited one
	
	Client: Móveis Simonetti

*/

-- getLastVisitedMagentoId
---- Obtém o ID do último produto visualizado no site (14/08/2025)

SELECT
TOP 1 E.item_name, E.magento_id
FROM dt_Events AS E
WHERE 
    E.event_type = 'view_item' 
AND E.email = @email
ORDER BY timestamp DESC

-- getLastVisitedProduct
---- Obtém o último produto visitado no site (14/08/2025)

SELECT
name, 
FORMAT(S.price, 'C2', 'pt-BR') AS price, 
CONCAT('https://mediacdn.simonetti.com.br/media/catalog/product', url_image) AS url_image, 
CONCAT('https://simonetti.com.br/', url_key) AS url_key
FROM dt_Sku_Magento AS S
WHERE 
    visibility = 4
AND id = @id

-- getLastViewedCategoryInWebsite
---- Obtém a última categoria visualizada no site (14/08/2025)

SELECT
TOP 1 E.timestamp, E.item_category, C.id AS category_id, item_name AS visited_item_name, magento_id
FROM dt_Events AS E
INNER JOIN dt_Category_Magento AS C
  ON C.Name = E.item_category
INNER JOIN dt_Sku_Magento AS S
  ON CHARINDEX(',' + CAST(C.id AS VARCHAR(20)) + ',', ',' + S.category_id + ',') > 0
WHERE 
    event_type = 'view_item' 
AND E.email = @email
AND C.is_active = 1
AND S.visibility = 4
GROUP BY E.timestamp, E.item_category, C.id, item_name, magento_id
ORDER BY timestamp DESC

-- getProductsOfInformedCategoryId
---- Obtém produtos do ID de categoria informado (14/08/2025)

SELECT
TOP 6 name, 
FORMAT(S.price, 'C2', 'pt-BR') AS price, 
CONCAT('https://mediacdn.simonetti.com.br/media/catalog/product', url_image) AS url_image, 
CONCAT('https://simonetti.com.br/', url_key) AS url_key, 
category_id
FROM dt_Sku_Magento AS S
WHERE 
    category_id LIKE CONCAT('%', @categoryId ,'%')
AND visibility = 4
ORDER BY NEWID()

/*

<h3>O produto visitado: </h3>

<var magento_id="GetRowsByTemplate('getLastVisitedMagentoId', new [] { new Param('email', SubscriberEmail) })"/>
<var visited="GetRowsByTemplate('getLastVisitedProduct', new [] { new Param('id', magento_id[0]['magento_id']) })"/>

<if condition="magento_id.Count > 0">
    <if condition="visited.Count > 0">
       ${visited[0]['name']} <br>
       ${visited[0]['url_image']} <br>
       ${visited[0]['url_key']} <br/>
    </if>
    <else>
      Não tem visited
    </else>
</if>
<else>
  Não tem magento_id
</else>

<hr />

<h3>As recomendações: </h3>
<var id="GetRowsByTemplate('getLastViewedCategoryInWebsite', new [] { new Param('email', SubscriberEmail) })"/>
<var products="GetRowsByTemplate('getProductsOfInformedCategoryId', new [] { new Param('categoryId', id[0]['category_id'].ToString()) })"/>
<if condition="id.Count > 0">
  <h4>Categoria visitada em Eventos: ${id[0]['category_id']}</h4>
	   <if condition="products.Count > 0">
       ${products[0]['name']} <br>
       ${products[0]['url_image']} <br>
       ${products[0]['url_key']} <br/>
       Categoria em Sku: ${products[0]['category_id']} <br/>
   </if>
   <else>  
     Não tem nenhum produto
   </else>
   <br/>
   <if condition="products.Count > 1">
       ${products[1]['name']} <br>
       ${products[1]['url_image']} <br>
       ${products[1]['url_key']} <br/>
       Categoria em Sku: ${products[1]['category_id']} <br/>
   </if>
   <else>  
     Não tem dois produtos
   </else>
   <br/>
   <if condition="products.Count > 2">
       ${products[2]['name']} <br>
       ${products[2]['url_image']} <br>
       ${products[2]['url_key']} <br/>
       Categoria em Sku: ${products[2]['category_id']} <br/>
   </if>
   <else>  
     Não tem três produtos
   </else>
   <br/>
   <if condition="products.Count > 3">
       ${products[3]['name']} <br>
       ${products[3]['url_image']} <br>
       ${products[3]['url_key']} <br/>
       Categoria em Sku: ${products[3]['category_id']} <br/>
   </if>   
   <else>  
     Não tem quatro produtos
   </else>
   <br/>
   <if condition="products.Count > 4">
       ${products[4]['name']} <br>
       ${products[4]['url_image']} <br>
       ${products[4]['url_key']} <br/>
       Categoria em Sku: ${products[4]['category_id']} <br/>
   </if>
   <else>  
     Não tem cinco produtos
   </else>
   <br/>
   <if condition="products.Count > 5">
       ${products[5]['name']} <br>
       ${products[5]['url_image']} <br>
       ${products[5]['url_key']} <br/>
       Categoria em Sku: ${products[5]['category_id']} <br/>
   </if>   
   <else>  
     Não tem seis produtos
   </else>
   <br/>
</if>
<else>
  Não tem categoria visitada
</else>


*/