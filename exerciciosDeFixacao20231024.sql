CREATE DATABASE exercicios_trigger;
USE exercicios_trigger;

-- Criação das tabelas
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE Auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

-- 1
create trigger data_hora after insert on clientes
	for each row insert into auditoria(mensagem)
    values ('Novo cliente adicionado');
    
insert into clientes
values (1, 'Ana');    

select * from auditoria;
select * from clientes;


-- 2
create trigger exclusao before delete on clientes
	for each row insert into auditoria(mensagem)
    values (concat('Tentativa de exclusão de ', old.nome));
    
delete from clientes where nome = "Ana";

select * from auditoria;
select * from clientes;

-- 3 
 insert into clientes
 values (2, 'Caio'), (3, 'Julia');  

create trigger atualizacao after update on clientes
    for each row insert into auditoria(mensagem)
	values (concat('O nome antigo era ', old.nome, ' agora é ', new.nome));

update clientes
set nome = 'Marcos'
where id = 2;

select * from auditoria;
select * from clientes;

-- 4
delimiter //
create trigger vazionao before update on clientes
for each row
begin
    if new.nome is null or new.nome = '' then
        insert into auditoria (mensagem)
        values (concat('Mudar para uma string vazia/null não pode ein'));
        set new.nome = old.nome;
    end if;
end;
//

update clientes
set nome = ''
where id = 3;

select * from auditoria;
select * from clientes;

-- 5
insert into pedidos 
values(1, 2, 3);

insert into produtos
values(1,"Camiseta", 7);

select * from auditoria;

delimiter //
create trigger estoquemenosque5nao after insert on pedidos
for each row
begin
    update produtos
    set estoque = estoque - new.quantidade
    where id = new.produto_id;
    if (select estoque from produtos where id = new.produto_id) < 5 then
        insert into auditoria (mensagem)
        values (concat('O estoque do produto de id ', new.produto_id, ' está abaixo de 5 unidades ein, cuidado'));
    end if;
end;
//
