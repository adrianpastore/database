--1) Crie consultas SQL para as seguintes necessidades:
--a. Os funcionários (nome, sexo e salário) com salário maior que R$2.000

SELECT nome, sexo, salario FROM Funcionario
WHERE salario > 2000

--b. Os funcionários (nome, cpf) com „cadu‟ ou “carla” no nome ou no login (desconsiderar maiúsculas e minúsculas.

SELECT nome, cpf FROM Funcionario
WHERE lower(nome) like '%cadu%' or lower(nome) like '%carla%' or lower(login) like '%cadu%' or lower(login) like '%carla%' 

--c. Fazer o item b para os clientes comparando apenas o nome

SELECT nome, cpf FROM Cliente
WHERE lower(nome) like '%cadu%' or lower(nome) like '%carla%'

--d. Unir as consultas do item b e c em uma única consulta.

SELECT nome, cpf FROM Funcionario
WHERE lower(nome) like '%cadu%' or lower(nome) like '%carla%' or lower(login) like '%cadu%' or lower(login) like '%carla%'
UNION
SELECT nome, cpf FROM Cliente
WHERE lower(nome) like '%cadu%' or lower(nome) like '%carla%'

--e. Mostrar os diferentes codDepartamento existentes na tabela Funcionario.
SELECT distinct codDepartamento FROM Funcionario

--f. Mostrar todas as informações para cliente que possuem email no Hotmail ou gmail.
SELECT * FROM Cliente
WHERE email like '%gmail%' or email like 'hotmail'

--g. Mostrar todas as informações para funcionários com salário entre 2000 e 6000 e idade entre 20 anos e 40 anos
SELECT * from Funcionario
WHERE salario >= 2000 and salario <= 6000 and extract(year FROM age(dataNascimento))>= 20 and extract(year FROM age(dataNascimento))<= 40

--h. Ordene os funcionários pelo sexo (crescente) caso de empate pelo salário (decrescente)
SELECT * from Funcionario
order by sexo asc, salario desc

--i. Os clientes ordenados pelo nome.

SELECT * from Cliente
order by nome

--j. A média salarial e o maior e menor salário dos funcionários.
SELECT min(salario), max(salario), avg(salario) FROM Funcionario

--k. O item j por sexo
SELECT min(salario), max(salario), avg(salario) FROM Funcionario
order by sexo asc

--l. Os funcionários que também são clientes e que possuem salário menor que 4500. Ordene a resposta pela data de nascimento, do mais velho para o mais novo.

SELECT * FROM funcionario
WHERE salario < 4500 and NOME in
(Select Nome from cliente)
order by extract(year FROM age(dataNascimento)) desc

--m. Os funcionários que não são clientes.

SELECT * FROM Funcionario
WHERE NOME not in
(Select Nome from cliente)

--n. As vendas ordenadas por data
SELECT * FROM notafiscal order by dataVenda

--o. Quantas vendas por ano.
SELECT COUNT (extract(year from datavenda)) from notafiscal group by (extract(year from datavenda))

--p. CodProduto e total de itens vendidos ordenados pelo total vendido decrescente
SELECT sum(quantidade), codproduto from itemvenda group by codproduto order by sum(quantidade) desc


--2) Realize as consultas pedidas se necessário utilize Junções de tabelas.
--a. O nome dos funcionários e de seus respectivos departamentos.
SELECT funcionario.nome, departamento.nome FROM funcionario INNER JOIN departamento ON funcionario.codDepartamento = departamento.codDepartamento

--b. Quantas diferentes pessoas (todos seus dados) existem no banco de dados (clientes e funcionários).

SELECT * coalesce(c.nome, f.nome), coalesce(c.cpf,f.cpf), salario, email, FROM funcionario f FULL OUTER JOIN cliente c ON c.cpf = f.cpf WHERE c.codcliente IS NOT NULL

--c. A média salarial por sexo dos funcionários que não são clientes e têm mais de 30 anos.
SELECT sexo, avg(salario) as mediaSalarial FROM funcionario WHERE extract(year FROM age(dataNascimento))> 30 and nome NOT IN (SELECT nome FROM cliente) GROUP BY sexo

--d. O item 1.j agrupado por nome do departamento e ordenado pelo nome do departamento para funcionários do sexo masculino com salário maior que 2000
SELECT min(salario), max(salario), avg(salario), departamento.nome 
FROM funcionario INNER JOIN departamento ON funcionario.codDepartamento = departamento.codDepartamento 
WHERE sexo = 'M' and salario > 2000
GROUP BY departamento.nome
ORDER BY departamento.nome


--e. A descrição dos produtos bem como o número de itens que foram vendidos, ordenado pelo número de itens que foram vendidos.
--todos os produtos e total em R$ vendido 
SELECT p.codproduto, p.descricao, sum(iv.quantidade*iv.precounitvenda) AS totalReaisP 
FROM produto p LEFT OUTER JOIN itemVenda iv ON p.codproduto = iv.codproduto 
GROUP BY p.codproduto
ORDER BY p.descricao
--Resposta exercício
SELECT p.codproduto, p.descricao, sum(iv.quantidade) as quant 
FROM Produto p INNER JOIN ItemVenda iv ON p.codproduto = iv.codproduto
GROUP BY p.codproduto
ORDER BY quant


 --f. A descrição e número de vezes que cada produto foi vendido, ordenado pelo número de vezes que foi vendido.
SELECT iv.codproduto, p.descricao, COUNT(iv.codproduto) 
FROM itemvenda iv INNER JOIN produto p ON iv.codproduto = p.codproduto 
GROUP BY p.descricao, iv.codProduto
ORDER BY iv.codProduto


--g. A listas dos clientes que mais vezes compram na loja. Nome e total de compras ordenado pelo total de compras.
SELECT nf.codcliente, COUNT(nf.codCliente) AS "Total de compras"
FROM notafiscal nf INNER JOIN cliente c ON nf.codcliente = c.codcliente
GROUP BY nf.codcliente
ORDER BY COUNT(nf.codcliente) desc


--h. A lista dos funcionários que mais vendas realizaram. Nome e total de vendas realizadas ordenado pelo total de vendas.
SELECT nf.codfuncionario AS "Codigo do Funcionario", COUNT(nf.codfuncionario) AS "Total de Vendas"
FROM notafiscal nf INNER JOIN funcionario f ON nf.codfuncionario = f.codfuncionario
GROUP BY nf.codfuncionario
ORDER BY COUNT(nf.codfuncionario) desc

--i. A lista dos departamentos e o total em vendas (R$) realizadas por cada departamento.
WITH CONS1 AS(
    SELECT dp.nome as "NomeDepto", f.coddepartamento FROM departamento dp 
    LEFT OUTER JOIN funcionario f 
    ON dp.coddepartamento = f.coddepartamento
    GROUP BY dp.nome, f.coddepartamento),
    CONS2 AS (
    SELECT f.coddepartamento, coalesce(sum(iv.quantidade*iv.precounitvenda),0) as totalVenda 
    FROM notafiscal nf INNER JOIN 
    itemVenda iv ON iv.quantidade=nf.codnotafiscal
        RIGHT OUTER JOIN funcionario f ON f.codfuncionario = nf.codfuncionario
        GROUP BY f.coddepartamento)
SELECT CONS1."NomeDepto", CONS2.totalVenda FROM CONS1 INNER JOIN CONS2 ON CONS1.coddepartamento = CONS2.coddepartamento
GROUP BY CONS1."NomeDepto", CONS2.totalVenda


--j. Sobre os clientes que são funcionários mostrar o nome, o total em vendas realizadas (R$) e o total em compras realizadas (R$)

with cons1 as(
    SELECT c.cpf, c.nome, coalesce(sum(iv.quantidade*iv.precounitvenda),0) as totalCompra
    FROM notafiscal nf INNER JOIN 
    itemVenda iv ON iv.codnotafiscal = nf.codnotafiscal
        RIGHT OUTER JOIN cliente c ON c.codcliente = nf.codcliente
        GROUP BY c.codcliente),
    cons2 AS (SELECT f.cpf, f.nome, coalesce(sum(iv.quantidade*iv.precounitvenda),0)as totalVenda 
    FROM notafiscal nf INNER JOIN 
    itemVenda iv ON iv.quantidade=nf.codnotafiscal
        RIGHT OUTER JOIN funcionario f ON f.codfuncionario = nf.codfuncionario
        GROUP BY f.codfuncionario) 
SELECT cons1.*, cons2.totalVenda from cons1 INNER JOIN cons2 ON cons1.cpf = cons2.cpf


--k. O nome e a média em compras (R$) para os clientes que compraram em média acima de R$30 em cada compra.





--l. Nome do cliente, do funcionário e o total da compra para vendas realizadas no último mês.

SELECT f.nome as func, c.nome as cli, sum(iv.quantidade*iv.precounitvenda) as totalCompra, nf.datavenda FROM notafiscal nf INNER JOIN
    itemVenda iv ON iv.codnotafiscal = nf.codnotafiscal
    INNER JOIN cliente c ON c.codcliente = nf.codcliente
    INNER JOIN funcionario f ON f.codfuncionario = nf.codfuncionario
        WHERE age(nf.datavenda) < interval '1 mon'
            GROUP BY nf.codnotafiscal, f.nome, c.nome


--linha de teste de intervalos
SELECT interval '1 mon', age(nf.datavenda) FROM notafiscal nf


