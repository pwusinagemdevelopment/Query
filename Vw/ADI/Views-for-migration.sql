
/**
    0001
    Status = ok
*//*View: CS_LOTES*/
CREATE VIEW CS_LOTES(
    LOTE,
    CODIGOITEM,
    QTDETOTAL,
    SALDOLOTE,
    POSICAO,
    ENTRADA,
    CODFOR,
    NOTA_FISCAL,
    TIPO,
    OS,
    TBFORFAN,
    NOMEITEM,
    UND,
    COMPRIM,
    LARGURA,
    ESPESSURA,
    TIPO_ITEM,
    ORIGEM,
    QTDE_RESERV,
    ESTOQUE_FISICO,
    VALIDADE,
    VLD,
    DESENHOITEM,
    CUSTO,
    VALIDACAO)
AS
select lote, tblote.codigoitem, qtdetotal, saldolote,
case
when posicao = 'PENDENTE' then 'AG.INSP.'
ELSE POSICAO
END,
tblote.entrada, codfor, nota_fiscal, tblote.tipo, os,
tbforfan,
nomeitem, undusoitem, comprimitem, larguraitem, espessuraitem, TBITENS.tipoitem, origem, qtde_reserv, saldolote + (qtde_reserv),
cast(f_addday(TBLOTE.entrada,TBTIPOITEM.prazo * TBLOTE.validacao) as t_data), TBLOTE.validacao, tbitens.desenhoitem,
case
when tbitensnfc.vlunit is null then tbitens.valorcustoitem
else ((tbitensnfc.vlunit / tbitens.fatorconvitem) * (1 - ((1.65 + 7.60 + tbitensnfc.icms)/100)))
end, tblote.validacao
from tblote left join tbfor on (tblote.codfor = tbfor.tbforcod)
left join (tbitens LEFT JOIN tbtipoitem ON (TBITENS.tipoitem = TBTIPOITEM.tipoitem)) on (tblote.codigoitem = tbitens.codigoitem)
left join tbitensnfc on (tblote.lote = tbitensnfc.nr);

--=======================================================================================================================================
/**
    0002
    Status = ok
*//*View: MOVIMENTO*/
CREATE VIEW MOVIMENTO(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    QTDCOMPRA,
    QTDENTRADA,
    QTDINSPECAO,
    QTDSAIDA,
    SETOR,
    SALDOCOMPRA,
    SALDOINSPECAO,
    SALDOFISICO,
    VALORMEDIO,
    VALORLANC,
    HISTORICO,
    UND,
    LOTE,
    SALDORESERV,
    SALDOSERV,
    SALDODISP,
    SALDOPROC,
    QTDERESERV,
    QTDESERV,
    QTDEPROC,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    REQUISICAO,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    VALOR_TOTAL,
    QTD_MOV,
    VALOR_MOV,
    VALOR_MEDIO,
    TIPO_ITEM,
    INVENTARIO,
    LOTE_OS,
    VALOR_INFORMADO,
    OS__ORIGEM,
    TBFORFAN)
AS
select idlanc, datasis, datalanc, tblanc.codigomat, idpedido, iditemped, docto, tblanc.os, qtdcompra, qtdentrada, qtdinspecao, qtdsaida, setor, saldocompra, saldoinspecao, saldofisico, valormedio,
case when
tbitens.custoacabitem > 0 then tbitens.custoacabitem 
else valorlanc
end,
historico, tblanc.und, tblanc.lote, saldoreserv, saldoserv, saldodisp, saldoproc, qtdereserv, qtdeserv, qtdeproc,
tblanc.cod_parametro, tblanc.cfop, tblanc.codfor, tblanc.requisicao, tblanc.nota_fiscal, 
nome_parametro, tbitens.nomeitem, tb_parametro_movimentacao.grupo, TBLANC.mes_lanc, TBLANC.status, TBLANC.usuario,
TBLANC.hora_lanc,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then TBITENS.custoacabitem * tblanc.qtdsaida
else TBITENS.custoacabitem * tblanc.qtdentrada
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then tblanc.valorlanc * tblanc.qtdsaida
else tblanc.valorlanc * tblanc.qtdentrada
end
end,
case
when tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then 0
when tblanc.qtdentrada <> 0 then tblanc.qtdentrada
when tblanc.qtdsaida <> 0 then (tblanc.qtdsaida * -1)
else 0
end,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (TBITENS.custoacabitem * tblanc.qtdsaida) * -1
when tbitens.custoacabitem > 0 and tblanc.qtdentrada <> 0 then (tbitens.custoacabitem * tblanc.qtdentrada)
else 0
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valorlanc * tblanc.qtdsaida)* -1
when tblanc.valorlanc > 0 and tblanc.qtdentrada <> 0 then (tblanc.valorlanc * tblanc.qtdentrada)
else 0
end
end,
case
when tblanc.valorMEDIO > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valormedio
when tblanc.valormedio > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valormedio * tblanc.qtdsaida)
when tblanc.valormedio > 0 and tblanc.qtdentrada <> 0 then (tblanc.valormedio * tblanc.qtdentrada)
else 0
end,
tbitens.tipoitem, tbtipoitem.inventario,
case
when tbitens.tipoitem = 'PRODUTO ACABADO' THEN TBLANC.os
when tbitens.tipoitem = 'COMPONENTE FABRICADO' THEN TBLANC.OS
when tbitens.tipoitem = 'COMPONENTE COMPRADO' THEN TBLANC.lote 
when tbitens.tipoitem = 'MAT�RIA-PRIMA' THEN TBLANC.LOTE
END,
tbitens.custoacabitem, cs_lotes.os, cs_lotes.tbforfan
from tblanc left join tbitens on (codigomat = codigoitem)
left join tb_parametro_movimentacao on (tblanc.cod_parametro = tb_parametro_movimentacao.cod_parametro)
left join tbtipoitem on (tbitens.tipoitem = tbtipoitem.tipoitem)
left join cs_lotes on (tblanc.lote = cs_lotes.lote);
--=============================================================================================================================
/**
    0003
    Status = ok
    Modificado por: Gerson
*//*View: ALTERA_ET*/
CREATE VIEW ALTERA_ET(
    IDLANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    COD_PARAMETRO,
    MES_LANC,
    ET)
AS
select idlanc, codigomat, idpedido, iditemped, docto, cod_parametro, mes_lanc,
tbarvoreproc.codigoitem
from movimento left join tbarvoreproc on (codigomat = tbarvoreproc.produto) where cod_parametro = '01.10' and
mes_lanc = '12/2008' and idpedido is null and tbarvoreproc.codigoitem is not null;
--================================================================================================================
/**
    0004
    Status = ok
*//*View: ANDAMENTO*/
CREATE VIEW ANDAMENTO(
    PRODUTO,
    SALDO,
    SEM_OS)
AS
select produto, sum(saldo), sem_os
from tb_os group by produto, sem_os order by produto;
--================================================================================================================
/**
    0005
    Status = ok
*//*View: ANDAMENTO_MENSAL*/
CREATE VIEW ANDAMENTO_MENSAL(
    PRODUTO,
    SALDO,
    MES_OS)
AS
select produto, sum(saldo) + sum(tb_os.total_terceiro), f_year(TB_OS.prazo_entrega) || f_padleft(F_MONTH(TB_OS.prazo_entrega), '0',4)
from tb_os where tb_os.status in ('EM PROCESSO','EM TERCEIRO') AND TB_OS.prazo_entrega IS NOT NULL
group by produto, f_year(TB_OS.prazo_entrega) || f_padleft(F_MONTH(TB_OS.prazo_entrega), '0',4) order by produto, f_year(TB_OS.prazo_entrega) || f_padleft(F_MONTH(TB_OS.prazo_entrega), '0',4);
--================================================================================================================
/**
    0006
    Status = ok
*//* View: APLICET */
CREATE VIEW APLICET(
    ET,
    TIPO,
    CODIGO,
    ULTREV,
    DESCRCODIGO,
    CODIGOAPLIC,
    DESCRAPLIC,
    DESENHOAPLIC)
AS
select et, tipo, codigo, ultrev, descrcodigo,
codigoaplic, descraplic, desenhoaplic from tbet left join tbetaplic on (et = idet);
--================================================================================================================
/**
    0007
    Status = ok
*//* View: APONTAMENTOS */
CREATE VIEW APONTAMENTOS(
    ID,
    EVENTO,
    DATA,
    INSPECAO,
    USUARIO,
    OS,
    QTDE,
    DESCRICAO_EVENTO,
    OPERACAO,
    CODIGO,
    HORAS,
    TURNO,
    OPERADOR,
    ID_ESTRUT,
    MAQUINA,
    CONTROLE,
    STATUS,
    LAUDO,
    DISPOSICAO,
    RESPONSAVEL,
    EMAIL,
    LIBERACAO,
    ABERTURA,
    ETIQUETAS,
    LOTES,
    TOTAL,
    AMOSTRA,
    REPROVADO,
    CONSEQUENCIA,
    SCRAP,
    LOCALIZACAO,
    INSPETOR,
    AMOSTRA_LOTE,
    PROGRAMA)
AS
select a.id, evento,
a.data,
case
when b.liberacao is not null then b.liberacao
when b.data_abertura is not null then b.data_abertura
else a.data
end
, a.usuario, a.os, a.qtde, a.descricao_evento, a.operacao, a.codigo, a.horas, a.turno, a.operador, a.id_estrut, a.maquina,
coalesce(a.controle,0),
case
when a.qtde = 0 then 'CONTAGEM'
when coalesce(a.controle,0)=0 then 'PENDENTE'
when b.disposicao = 'PENDENTE' AND coalesce(a.controle,0)>0 THEN 'INSPE��O'
when b.laudo = 'REPROVADO' then 'REPROVADO'
when b.laudo = 'APROVADO' and b.reprovado>0 then 'APROVADO PARCIAL'
when b.laudo = 'APROVADO' and b.reprovado=0 then 'APROVADO'
when b.disposicao = 'SELE��O' and b.laudo = 'PENDENTE' then 'SELE��O'
when b.disposicao = 'RETRABALHO' AND b.laudo = 'PENDENTE' then 'RETRABALHO'
when b.disposicao = 'SUCATA' AND b.laudo = 'PENDENTE' then 'INSPE��O'
when b.disposicao = 'APROVA��O CONDICIONAL' AND b.laudo = 'PENDENTE' then 'INSPE��O'
when b.disposicao = 'REPROVADO' AND b.laudo = 'PENDENTE' then 'INSPE��O'
when b.disposicao = 'APROVADO' AND b.laudo = 'PENDENTE' then 'INSPE��O'
end
,case when b.laudo is null then 'PENDENTE'
else b.laudo
end,
case when b.disposicao is null then 'PENDENTE'
ELSE b.disposicao
end, b.responsavel, b.email, b.liberacao, b.data_abertura,
b.etiquetas, b.lotes, b.total, b.amostra, b.reprovado, b.consequencia, b.scrap, b.localizacao, b.usuario,
c.amostra, d.programa
from tb_eventos_os a left join tb_laudo b on (a.controle = b.controle)
left join tb_amostragem c on (a.qtde = c.qtde)
left join tb_of d on (a.os = d.numof)
order by a.id desc;
--================================================================================================================
/**
    0008
    Status = ok
*//*View: APONTAMENTOS_ARLON*/
CREATE VIEW APONTAMENTOS_ARLON(
    ID,
    EVENTO,
    DATA,
    INSPECAO,
    USUARIO,
    OS,
    QTDE,
    DESCRICAO_EVENTO,
    OPERACAO,
    CODIGO,
    HORAS,
    TURNO,
    OPERADOR,
    ID_ESTRUT,
    MAQUINA,
    CONTROLE,
    STATUS,
    LAUDO,
    DISPOSICAO,
    RESPONSAVEL,
    EMAIL,
    LIBERACAO,
    ABERTURA,
    ETIQUETAS,
    LOTES,
    TOTAL,
    AMOSTRA,
    REPROVADO,
    CONSEQUENCIA,
    SCRAP,
    LOCALIZACAO,
    INSPETOR)
AS
select a.id, evento,
a.data,
case
when b.liberacao is not null then b.liberacao
when b.data_abertura is not null then b.data_abertura
else a.data
end
, a.usuario, a.os, a.qtde, a.descricao_evento, a.operacao, a.codigo, a.horas, a.turno, a.operador, a.id_estrut, a.maquina,
coalesce(a.controle,0),
case
when a.qtde = 0 then 'CONTAGEM'
when coalesce(a.controle,0)=0 then 'PENDENTE'
when b.disposicao = 'PENDENTE' AND coalesce(a.controle,0)>0 THEN 'INSPE��O'
when b.laudo = 'REPROVADO' then 'REPROVADO'
when b.laudo = 'APROVADO' and b.reprovado>0 then 'APROVADO PARCIAL'
when b.laudo = 'APROVADO' and b.reprovado=0 then 'APROVADO'
when b.disposicao = 'SELE��O' and b.laudo = 'PENDENTE' then 'SELE��O'
when b.disposicao = 'RETRABALHO' AND b.laudo = 'PENDENTE' then 'RETRABALHO'
when b.disposicao = 'SUCATA' AND b.laudo = 'PENDENTE' then 'INSPE��O'
when b.disposicao = 'APROVA��O CONDICIONAL' AND b.laudo = 'PENDENTE' then 'INSPE��O'
when b.disposicao = 'REPROVADO' AND b.laudo = 'PENDENTE' then 'INSPE��O'
when b.disposicao = 'APROVADO' AND b.laudo = 'PENDENTE' then 'INSPE��O'
end
,case when b.laudo is null then 'PENDENTE'
else b.laudo
end,
case when b.disposicao is null then 'PENDENTE'
ELSE b.disposicao
end, b.responsavel, b.email, b.liberacao, b.data_abertura,
b.etiquetas, b.lotes, b.total, b.amostra, b.reprovado, b.consequencia, b.scrap, b.localizacao, b.usuario
from tb_eventos_os a left join tb_laudo b on (a.controle = b.controle)
order by a.id desc;
--================================================================================================================
/**
    0009
    Status = ok
*//*View: RECURSOS*/
CREATE VIEW RECURSOS(
    MAQUINA,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    CAPT1,
    CAPT2,
    CAPT3,
    CAPTOTDIA,
    CAPTOTMES,
    GRUPO,
    TIPO,
    NOME_GRUPO)
AS
select a.idrec, a.nomerec, b.idsetor, b.nomesetor,
a.t1realqtd * a.t1realhs,
a.t2realqtd * a.t2realhs,
a.t3realqtd * a.t3realhs,

(a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs),

((a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs))*a.dias_disp_mes,

c.idccusto, c.tipomo, C.nome
from tbrecurso a left join tbsetor b on (a.idsetor = b.idsetor)
left join ccusto c on (b.idccusto = c.idccusto)
order by a.idrec;
--================================================================================================================
/**
    0010
    Status = ok
*//*View: APONTAMENTOS_PRODUCAO */
CREATE VIEW APONTAMENTOS_PRODUCAO(
    DATA,
    QTDE,
    OPERACAO,
    CODIGO,
    HORAS,
    TURNO,
    OPERADOR,
    MAQUINA,
    SETOR,
    PCHORA,
    TURNO1,
    TURNO2,
    TURNO3,
    MES_ENTRADA)
AS
select a.data,
sum(a.qtde), a.operacao, a.codigo, a.horas, a.turno, a.operador, a.maquina,
f.nome_setor, COALESCE(f_roundcommon(e.pcshora,0),0),
f.capt1,
f.capt2,
f.capt3,
f_YEAR(A.data)||'-'||f_padleft(f_month(a.data),'0',2)
from tb_eventos_os a
left join tbitens e on (a.codigo = e.codigoitem)
left join recursos f on (a.maquina = f.maquina)
WHERE a.evento IN ('MAQUINA')
group by
a.data,
a.operacao, a.codigo, a.horas, a.turno, a.operador, a.maquina,
f.nome_setor, COALESCE(f_roundcommon(e.pcshora,0),0),
f.capt1,
f.capt2,
f.capt3,
f_YEAR(A.data)||'-'||f_padleft(f_month(a.data),'0',2);
--================================================================================================================
/**
    0011
    Status = ok
*//*View: APONTAMENTOS_REFUGO */
CREATE VIEW APONTAMENTOS_REFUGO(
    ID,
    EVENTO,
    DATA,
    DATA_INSPECAO,
    USUARIO,
    OS,
    QTDE,
    DESCRICAO_EVENTO,
    OPERACAO,
    CODIGO,
    HORAS,
    TURNO,
    OPERADOR,
    ID_ESTRUT,
    MAQUINA,
    CONTROLE,
    DISPOSICAO,
    LAUDO,
    RESPONSAVEL,
    EMAIL,
    LIBERACAO,
    ABERTURA,
    ETIQUETAS,
    LOTES,
    TOTAL,
    AMOSTRA,
    REPROVADO,
    CONSEQUENCIA,
    SCRAP,
    LOCALIZACAO,
    INSPETOR,
    AMOSTRA_LOTE,
    PROGRAMA,
    MES,
    PRECO,
    VALOR_TOTAL,
    VALOR_LOTE,
    VALOR_SUCATA,
    VALOR_REPROVADO,
    MES_EXTENSO,
    PCSTURNO,
    SETOR,
    PCHORA)
AS
select a.id, evento, a.data,
case
when b.liberacao is not null then b.liberacao
when b.data_abertura is not null then b.data_abertura
else a.data
end,

a.usuario, a.os, a.qtde, a.descricao_evento, a.operacao, a.codigo, a.horas, a.turno, a.operador, a.id_estrut, a.maquina,
coalesce(a.controle,0),
case
when a.qtde = 0 then 'CONTAGEM'
when b.disposicao is null and a.qtde > 0 then 'PENDENTE'
when coalesce(a.controle,0)=0 then 'PENDENTE'
when b.disposicao = 'PENDENTE' AND coalesce(a.controle,0)>0 THEN 'INSPE��O'
ELSE b.disposicao 
end
,case when b.laudo is null then 'PENDENTE'
else b.laudo
end,
b.responsavel, b.email, b.liberacao, b.data_abertura,
b.etiquetas, b.lotes, b.total, b.amostra, b.reprovado, b.consequencia, b.scrap, b.localizacao, b.usuario,
c.amostra, d.programa, d.entrega, COALESCE((e.precovenda/e.fatorconven),0),
COALESCE((e.precovenda/e.fatorconven),0)*d.programa, COALESCE((e.precovenda/e.fatorconven),0)* a.qtde,
COALESCE((e.precovenda/e.fatorconven),0)* coalesce(b.scrap,0) , COALESCE((e.precovenda/e.fatorconven),0)* coalesce(b.reprovado,0),
f_cmonthshortlang(d.entrega,'PT')||'/'||f_year(d.entrega), f_roundcommon(e.pcshora * f.capt1,0),
f.nome_setor, f_roundcommon(e.pcshora,0)
from tb_eventos_os a left join tb_laudo b on (a.controle = b.controle)
left join tb_amostragem c on (a.qtde = c.qtde)
left join tb_of d on (a.os = d.numof)
left join tbitens e on (a.codigo = e.codigoitem)
left join recursos f on (a.maquina = f.maquina)
WHERE a.evento = 'REFUGO'
order by a.id desc;
--================================================================================================================
/**
    0012
    Status = ok
*//*View:  APONTAMENTOS_VALOR */
CREATE VIEW APONTAMENTOS_VALOR(
    ID,
    EVENTO,
    DATA,
    DATA_INSPECAO,
    USUARIO,
    OS,
    QTDE,
    DESCRICAO_EVENTO,
    OPERACAO,
    CODIGO,
    HORAS,
    TURNO,
    OPERADOR,
    ID_ESTRUT,
    MAQUINA,
    CONTROLE,
    DISPOSICAO,
    LAUDO,
    RESPONSAVEL,
    EMAIL,
    LIBERACAO,
    ABERTURA,
    ETIQUETAS,
    LOTES,
    TOTAL,
    AMOSTRA,
    REPROVADO,
    CONSEQUENCIA,
    SCRAP,
    LOCALIZACAO,
    INSPETOR,
    AMOSTRA_LOTE,
    PROGRAMA,
    MES,
    PRECO,
    VALOR_TOTAL,
    VALOR_LOTE,
    VALOR_SUCATA,
    VALOR_REPROVADO,
    MES_EXTENSO,
    PCSTURNO,
    SETOR,
    PCHORA,
    SETOR_CADASTRO,
    CLIENTE,
    HORA_LIBERADA,
    TURNO1,
    TURNO2,
    TURNO3,
    LEAD_TIME_LIBERACAO,
    MES_ENTRADA)
AS
select a.id, evento, a.data,
case
when b.liberacao is not null then b.liberacao
when b.data_abertura is not null then b.data_abertura
else a.data
end,

a.usuario, a.os, a.qtde, a.descricao_evento, a.operacao, a.codigo, a.horas, a.turno, a.operador, a.id_estrut, a.maquina,
coalesce(a.controle,0),
case
when a.qtde = 0 then 'CONTAGEM'
when b.disposicao is null and a.qtde > 0 then 'PENDENTE'
when coalesce(a.controle,0)=0 then 'PENDENTE'
when b.disposicao = 'PENDENTE' AND coalesce(a.controle,0)>0 THEN 'INSPE��O'
ELSE b.disposicao 
end
,case when b.laudo is null then 'PENDENTE'
else b.laudo
end,
b.responsavel, b.email, b.liberacao, b.data_abertura,
b.etiquetas, b.lotes, b.total, b.amostra, b.reprovado, b.consequencia, b.scrap, b.localizacao, b.usuario,
c.amostra, d.programa, d.entrega, COALESCE((e.precovenda/e.fatorconven),0),
COALESCE((e.precovenda/e.fatorconven),0)*d.programa, COALESCE((e.precovenda/e.fatorconven),0)* a.qtde,
COALESCE((e.precovenda/e.fatorconven),0)* coalesce(b.scrap,0) , COALESCE((e.precovenda/e.fatorconven),0)* coalesce(b.reprovado,0),
f_cmonthshortlang(d.entrega,'PT')||'/'||f_year(d.entrega),

CASE WHEN f_dayofweek(a.data) = 7 then
COALESCE(f_roundcommon(h.pchora * 9,0),0)
else
COALESCE(f_roundcommon(h.pchora * f.capt1,0),0)
end,

case WHEN H.setor IS null THEN
f.nome_setor
else
H.setor
END, COALESCE(f_roundcommon(h.pchora,0),0), h.setor, g.tbforfan, b.hora_liberada, f.capt1, f.capt2, f.capt3,
case when b.liberacao is null
then (current_date - a.data)
else
(b.liberacao - a.data)
end, f_YEAR(A.data)||'-'||f_padleft(f_month(a.data),'0',2)
from tb_eventos_os a left join tb_laudo b on (a.controle = b.controle)
left join tb_amostragem c on (a.qtde = c.qtde)
left join tb_of d on (a.os = d.numof)
left join (tbitens e left join tbfor g on (e.codclitem = g.tbforcod)
left join tb_roteiro_simples h on (e.codigoitem = h.codigo and a.operacao = h.ciclo))
on (a.codigo = e.codigoitem)
left join recursos f on (a.maquina = f.maquina)
WHERE a.evento IN ('PRODUCAO')
order by a.id desc;
--================================================================================================================
/**
    0013
    Status = ok
*//*View:  ARVORE_VALIDA*/
CREATE VIEW ARVORE_VALIDA(
    COD_ARVORE,
    MAT_ARVORE,
    PROC_ARVORE)
AS
select tbarvore.arvore, tbarvoremat.arvore,
tbarvoreproc.arvore from tbarvore left join tbarvoremat on (TBARVORE.arvore = TBARVOREMAT.arvore)
left join tbarvoreproc on (TBARVORE.ARVORE = TBARVOREPROC.ARVORE)
WHERE (TBARVOREMAT.arvore IS not NULL) and (TBARVOREPROC.arvore is not NULL)
group by tbarvore.arvore, tbarvoremat.arvore,
tbarvoreproc.arvore;
--================================================================================================================
/**
    0014
    Status = ok
*//*View:  AUDITORIA*/
CREATE VIEW AUDITORIA(
    ID_REGISTRO,
    ID_AUDITORIA,
    COD_ENTIDADE,
    DATA_CRIACAO,
    PRAZO_AUDITORIA,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    AUDITOR,
    NOME_AUDITORIA,
    TIPO_AUDITORIA)
AS
select id_registro, TB_AUDITORIA.id_auditoria, cod_entidade, data_criacao, prazo_auditoria, nota_avaliacao, status_avaliacao, prox_auditoria, auditor,
nome_auditoria, tipo_auditoria from tb_auditoria  JOIN TB_TIPO_AUDITORIA ON TB_AUDITORIA.id_auditoria = TB_TIPO_AUDITORIA.id_auditoria;
--================================================================================================================
/**
    0015
    Status = ok
*//*View:  AUDITORIA_FORNECEDOR*/
CREATE VIEW AUDITORIA_FORNECEDOR(
    ID_REGISTRO,
    ID_AUDITORIA,
    COD_ENTIDADE,
    DATA_CRIACAO,
    PRAZO_AUDITORIA,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    AUDITOR,
    NOME_AUDITORIA,
    TIPO_AUDITORIA,
    ENTIDADE,
    NOME_AUDITOR)
AS
select auditoria.*,tbforraz, usernome from auditoria left join tbfor on (cod_entidade = tbforcod)
left join tb_user on (auditor = userid) where tipo_auditoria in ('FORNECEDOR','CLIENTE');
--================================================================================================================
/**
    0016
    Status = ok
    *//*View:  AUDITORIA_PROCESSO*/
CREATE VIEW AUDITORIA_PROCESSO(
    ID_REGISTRO,
    ID_AUDITORIA,
    COD_ENTIDADE,
    DATA_CRIACAO,
    PRAZO_AUDITORIA,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    AUDITOR,
    NOME_AUDITORIA,
    TIPO_AUDITORIA,
    ENTIDADE,
    NOME_AUDITOR)
AS
select auditoria.*,TBSETOR.nomesetor,usernome from auditoria
left join TBSETOR on (cod_entidade = TBSETOR.ncc)
left join tb_user on (auditor = userid) where tipo_auditoria in ('PROCESSO');
--================================================================================================================
/**
    0017
    Status = ok
    *//*View:  AUDITORIA_PROCESSO*/
CREATE VIEW AUDITORIA_PRODUTO(
    ID_REGISTRO,
    ID_AUDITORIA,
    COD_ENTIDADE,
    DATA_CRIACAO,
    PRAZO_AUDITORIA,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    AUDITOR,
    NOME_AUDITORIA,
    TIPO_AUDITORIA,
    ENTIDADE,
    NOME_AUDITOR)
AS
select auditoria.*,TBITENS.nomeitem , usernome from auditoria
left join tbITENS on (cod_entidade = CODIGOITEM)
left join tb_user on (auditor = userid) where tipo_auditoria in ('PRODUTO','LAY-OUT');
--================================================================================================================
/**
    0018
    Status = ok
    *//*View:  AUDITORIA_PROCESSO*/
CREATE VIEW AUDITORIA_SISTEMA(
    ID_REGISTRO,
    ID_AUDITORIA,
    COD_ENTIDADE,
    DATA_CRIACAO,
    PRAZO_AUDITORIA,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    AUDITOR,
    NOME_AUDITORIA,
    TIPO_AUDITORIA,
    ENTIDADE,
    NOME_AUDITOR)
AS
select auditoria.*,tb_sistema_qualidade.processo  ,usernome from auditoria
left join tb_sistema_qualidade on (cod_entidade = ID_SISTEMA)
left join tb_user on (auditor = userid) where tipo_auditoria in ('SISTEMA');
--================================================================================================================
/**
    0019
    Status = ok
    *//*View:  AUDITORIAS_QUALIDADE*/
CREATE VIEW AUDITORIAS_QUALIDADE(
    COD_ENTIDADE,
    FORNECEDOR,
    ID_AUDITORIA,
    NOME_AUDITORIA,
    TIPO_AUDITORIA,
    PRAZO_AUDITORIA,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    INDICE_SISTEMA,
    CALCULO_IQF)
AS
select a.cod_entidade, c.tbforfan, a.id_auditoria, b.nome_auditoria, b.tipo_auditoria, A.prazo_auditoria, a.nota_avaliacao, a.status_avaliacao, a.prox_auditoria,
case when
current_date <= a.prox_auditoria then
case
when a.status_avaliacao = 'A' then 30
when a.status_avaliacao = 'B' then 10
when a.status_avaliacao = 'C' then 0
else 0
end
else 0
end,
CASE WHEN
calculo_iqf  = 1 THEN 'SIM'
ELSE 'N�O'
END
from tb_auditoria a left join tb_tipo_auditoria b on (a.id_auditoria = b.id_auditoria)
left join tbfor c on (a.cod_entidade = c.tbforcod)
WHERE A.id_auditoria > 0
ORDER by C.tbforfan, A.id_registro;
--================================================================================================================
/**
    0020
    Status = ok
    *//*View:  BASE_IQF*/
CREATE VIEW BASE_IQF(
    IQFAPP,
    IQFAPVAL,
    IQFIQEPONTOS,
    IQFREDUTOR,
    IQFAFP,
    IQFAFVAL,
    IQFPONTOS,
    IQFBASE,
    IQFAPV,
    IQFAFV,
    IQFPPM,
    IQFPPMAC,
    IQFPONTFINAL,
    IQFSIT,
    IQFLOTESTOTAL,
    IQFLOTESAPROV,
    IQFLOTESDESVIO,
    IQFLOTESUSAR,
    IQFLOTESAFETA,
    IQFLOTESREJ,
    IQFPERC,
    IQFTOTALENT,
    IQFTOTALREJ,
    IQFSTATUS,
    IQFOBS,
    IQFFORCOD,
    IQFIQEPERC,
    IQFCERT,
    IQFAP,
    IQFLOTESATRAZO,
    IQFLOTESFEXTRA,
    IQFDOCPEND,
    IQFNCPEND,
    IQFANO,
    IQFNMES)
AS
select IQFAPP, IQFAPVAL, IQFIQEPONTOS, IQFREDUTOR, IQFAFP, IQFAFVAL, IQFPONTOS, IQFBASE, IQFAPV, IQFAFV, IQFPPM, IQFPPMAC, IQFPONTFINAL, IQFSIT, IQFLOTESTOTAL, IQFLOTESAPROV, IQFLOTESDESVIO, IQFLOTESUSAR, IQFLOTESAFETA, IQFLOTESREJ, IQFPERC, IQFTOTALENT, IQFTOTALREJ, IQFSTATUS,IQFOBS, IQFFORCOD, IQFIQEPERC, IQFCERT, IQFAP, IQFLOTESATRAZO,IQFLOTESFEXTRA,IQFDOCPEND,IQFNCPEND,iqfano, iqfnmes  FROM IQF ORDER BY IQFANO DESC,IQFNMES DESC;
--================================================================================================================
/**
    0021
    Status = ok
    *//*View:  PEDIDO*/
CREATE VIEW PEDIDO(
    NPED,
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    LIBENGEPED,
    LIBENGEORC,
    DATAENV,
    PEDNOVO,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    TIPO_ITEM,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    UND,
    DESENHOITEM,
    REVDESENHOITEM,
    CODFATURAMITEM,
    SEMANA,
    ANOREF,
    FCVENDA,
    COMPLEMENTO,
    VTOTIPI,
    VORIPI,
    STPREV,
    MES,
    MESBASE,
    CFOPI,
    VLICMS,
    SALDOICMS,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    UNIDADE,
    CRITICO,
    PROB,
    ID_ORIGEM,
    PEDI_ORIGEM,
    ANOMES,
    CLIENTE_CADASTRO,
    ULTNF,
    DATAULTNF)
AS
select
tbprop.nped , numped, codcli, tbfor.tbforfan, cpag, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest, tbfor.tbforendercob, tbfor.tbforbairrocob, tbfor.tbforcepcob, tbfor.tbforcidcob, tbfor.tbforestcob,
tbfor.tbforenderent, tbfor.tbforbairroent, tbfor.tbforcepent, tbfor.tbforcident, tbfor.tbforestent, tbprop.tbforcodtransp, tbprop.tbfornometransp, tbprop.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, tbprop.obsped, entrada, tbprop.icms, tbprop.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, tbfor.tbforraz , tbprop.libengeped, tbprop.libengeorc, tbprop.dataenv,  TBPROP.pednovo,
iditem, idnumped, tbpropitem.codprod, TBITENS.nomeitem, tbitens.tipoitem,  descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, ipi, saldo, vlfaturar, prazo, pcp, prazopcp, posicao, opnum, pedidocli,und, tbpropitem.desenhoitem, tbpropitem.revdesenhoitem,tbitens.codfaturamitem,  semanaven, anoref, fcvenda ,tbpropitem.complemento,
case (ipi*vlfaturar)
when 0 then 0 else
(ipi*vlfaturar)/100
end,
case (ipi*vlitem)
when 0 then 0 else
(ipi*vlitem)/100
end, tbpropitem.status, upper(f_cmonthshortlang(prazo,'pt') || '/' || anoref), f_padleft(f_month(PRAZO),'0',2)  || '/' || anoref, cfopi,
((TBPROPITEM.vlitem * TBPROP.icms) / 100), ((TBPROPITEM.vlfaturar * TBPROP.icms) / 100)
, codigo_municipio, codigo_uf, endereco_numero, tbfor.complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob,
tbprop.unidade, case
when TBPROPITEM.semanapcp <> '1' THEN 'N�O'
ELSE 'SIM'
END, tbpropitem.ind_prob, tbpropitem.id_origem, tbpropitem.ped_origem, anoref||f_padleft(f_month(PRAZO),'0',2),
TBITENS.nomeclitem, ultnf, dataultnf
from tbprop left join tbpropitem left join tbitens  on (tbpropitem.codprod = tbitens.codigoitem)  on (tbprop.numped = tbpropitem.idnumped) left join tbfor on (tbprop.codcli = tbfor.tbforcod);
--================================================================================================================
/**
    0022
    Status = ok
    *//*View:  PROGRAMA_EDI_CLIENTE*/
CREATE VIEW PROGRAMA_EDI_CLIENTE(
    ID,
    ARQUIVO,
    EXPORTADO_ERP,
    PEDIDO_ERP,
    ITEM_PEDIDO_ERP,
    DATA_MOVIMENTO,
    HORA_MOVIMENTO,
    CNPJ_TRANSMISSOR,
    CNPJ_RECEPTOR,
    CODIGO_FABRICA,
    IDENTIFICACAO_PROGRAMA,
    DATA_PROGRAMA,
    CODIGO_ITEM_CLIENTE,
    PEDIDO_COMPRA_FECHADO,
    UNIDADE_MEDIDA,
    CASAS_DECIMAIS,
    TIPO_FORNECIMENTO,
    ULTIMA_NOTA,
    SERIE_ULTIMA_NOTA,
    DATA_ULTIMA_NOTA,
    TIPO_PROGRAMA,
    PEDIDO_REFERENCIA1,
    TIPO_PEDIDO,
    PEDIDO_REFERENCIA2,
    LOTE_PRODUCAO,
    PRAZO_ENTREGA_ITEM,
    HORA_ENTREGA,
    QUANTIDADE,
    CODIGO_CLIENTE,
    NOME_CLIENTE,
    NOME_EMPRESA,
    UNIDADE_EMPRESA,
    NOSSO_CODIGO,
    PRECO_VENDA,
    UND_VENDA,
    COND_PAGAMENTO,
    SEPPEN_ADI,
    PROGRAMA,
    ENTREGUE,
    SALDO,
    CANC,
    ULTNF,
    DATAULTNF,
    CODIGO_PEDIDO)
AS
select a.id, a.arquivo,
case
when a.exportado_erp = 0 then 'PENDENTE'
WHEN a.exportado_erp = 1 then 'INTEGRADO'
WHEN a.exportado_erp = 2 then 'CANCELADO'
END,e.numped, e.iditem, a.data_movimento,
a.hora_movimento, a.cnpj_transmissor, a.cnpj_receptor, a.codigo_fabrica, a.identificacao_programa,
a.data_programa, a.codigo_item_cliente, a.pedido_compra_fechado, a.unidade_medida,
a.casas_decimais, a.tipo_fornecimento, a.ultima_nota, a.serie_ultima_nota, a.data_ultima_nota,
a.tipo_programa, a.pedido_referencia1, a.tipo_pedido, a.pedido_referencia2, a.lote_producao,
a.prazo_entrega_item, a.hora_entrega, a.quantidade, b.tbforcod, b.tbforraz, c.fantasia, c.id, d.codigoitem, d.precovenda, d.undvenda, b.tbforcpag,
f_replace(d.revdesenhoitem,'-',''), e.qtdeped, e.qtdeent, e.saldo, e.qtdecanc, e.ultnf, e.dataultnf, e.codprod
from tb_programa_edi_cliente a
left join tb_planta b on (a.cnpj_transmissor = b.tbforcnpj and a.codigo_fabrica = b.tbforcheck1)
left join tbempresa c on (a.cnpj_receptor = c.cnpj)
left join tbitens d on (a.codigo_item_cliente = d.codfaturamitem)
left join pedido e on (a.pedido_referencia1 = e.pedidocli and b.tbforcod = e.codcli and b.tbforcheck1 = e.departam and a.prazo_entrega_item = e.prazo);
--================================================================================================================
/**
    0023
    Status = ok
    *//*View:  PROGRAMA_EDI_CLIENTE*/
CREATE VIEW CABECALHO_EDI_CLIENTE(
    ARQUIVO,
    CODIGO_FABRICA,
    IDENTIFICACAO_PROGRAMA,
    DATA_PROGRAMA,
    CODIGO_ITEM_CLIENTE,
    UNIDADE_MEDIDA,
    TIPO_FORNECIMENTO,
    ULTIMA_NOTA,
    SERIE_ULTIMA_NOTA,
    DATA_ULTIMA_NOTA,
    TIPO_PROGRAMA,
    CODIGO_CLIENTE,
    NOME_CLIENTE,
    NOME_EMPRESA,
    UNIDADE_EMPRESA,
    NOSSO_CODIGO,
    PRECO_VENDA,
    UND_VENDA)
AS
select a.arquivo, a.codigo_fabrica, a.identificacao_programa, a.data_programa, a.codigo_item_cliente, a.unidade_medida, a.tipo_fornecimento, a.ultima_nota, a.serie_ultima_nota, a.data_ultima_nota, a.tipo_programa, a.codigo_cliente, a.nome_cliente, a.nome_empresa, a.unidade_empresa, a.nosso_codigo, a.preco_venda, a.und_venda
from programa_edi_cliente a group by a.arquivo, a.codigo_fabrica, a.identificacao_programa, a.data_programa, a.codigo_item_cliente, a.unidade_medida, a.tipo_fornecimento, a.ultima_nota, a.serie_ultima_nota, a.data_ultima_nota, a.tipo_programa, a.codigo_cliente, a.nome_cliente, a.nome_empresa, a.unidade_empresa, a.nosso_codigo, a.preco_venda, a.und_venda;
--================================================================================================================
/**
    0024
    Status = ok
    *//*View:  PROGRAMA_EDI_CODIGO*/
CREATE VIEW PROGRAMA_EDI_CODIGO(
    ID,
    ARQUIVO,
    EXPORTADO_ERP,
    PEDIDO_ERP,
    ITEM_PEDIDO_ERP,
    DATA_MOVIMENTO,
    HORA_MOVIMENTO,
    CNPJ_TRANSMISSOR,
    CNPJ_RECEPTOR,
    CODIGO_FABRICA,
    IDENTIFICACAO_PROGRAMA,
    DATA_PROGRAMA,
    CODIGO_ITEM_CLIENTE,
    PEDIDO_COMPRA_FECHADO,
    UNIDADE_MEDIDA,
    CASAS_DECIMAIS,
    TIPO_FORNECIMENTO,
    ULTIMA_NOTA,
    SERIE_ULTIMA_NOTA,
    DATA_ULTIMA_NOTA,
    TIPO_PROGRAMA,
    PEDIDO_REFERENCIA1,
    TIPO_PEDIDO,
    PEDIDO_REFERENCIA2,
    LOTE_PRODUCAO,
    PRAZO_ENTREGA_ITEM,
    HORA_ENTREGA,
    QUANTIDADE,
    CODIGO_CLIENTE,
    NOME_CLIENTE,
    NOME_EMPRESA,
    UNIDADE_EMPRESA,
    NOSSO_CODIGO,
    PRECO_VENDA,
    UND_VENDA,
    COND_PAGAMENTO,
    SEPPEN_ADI,
    PROGRAMA,
    ENTREGUE,
    SALDO,
    CANC,
    ULTNF,
    DATAULTNF,
    CODIGO_PEDIDO)
AS
select a.id, a.arquivo,
case
when a.exportado_erp = 0 then 'PENDENTE'
WHEN a.exportado_erp = 1 then 'INTEGRADO'
WHEN a.exportado_erp = 2 then 'CANCELADO'
END,e.numped, e.iditem, a.data_movimento,
a.hora_movimento, a.cnpj_transmissor, a.cnpj_receptor, a.codigo_fabrica, a.identificacao_programa,
a.data_programa, a.codigo_item_cliente, a.pedido_compra_fechado, a.unidade_medida,
a.casas_decimais, a.tipo_fornecimento, a.ultima_nota, a.serie_ultima_nota, a.data_ultima_nota,
a.tipo_programa, a.pedido_referencia1, a.tipo_pedido, a.pedido_referencia2, a.lote_producao,
a.prazo_entrega_item, a.hora_entrega, a.quantidade, b.tbforcod, b.tbforraz, c.fantasia, c.id, d.codigoitem, d.precovenda, d.undvenda, b.tbforcpag,
f_replace(d.revdesenhoitem,'-',''), e.qtdeped, e.qtdeent, e.saldo, e.qtdecanc, e.ultnf, e.dataultnf, e.codprod 
from tb_programa_edi_cliente a
left join tb_planta b on (a.cnpj_transmissor = b.tbforcnpj and a.codigo_fabrica = b.tbforcheck1)
left join tbempresa c on (a.cnpj_receptor = c.cnpj)
left join tbitens d on (a.codigo_item_cliente = d.codfaturamitem)
left join pedido e on (a.pedido_referencia1 = e.pedidocli and b.tbforcod = e.codcli and b.tbforcheck1 = e.departam and a.prazo_entrega_item = e.prazo and a.codigo_item_cliente = e.codfaturamitem);
--================================================================================================================
/**
    0025
    Status = ok
    *//*View:  CABECALHO_EDI_CODIGO*/
CREATE VIEW CABECALHO_EDI_CODIGO(
    ARQUIVO,
    CODIGO_FABRICA,
    IDENTIFICACAO_PROGRAMA,
    DATA_PROGRAMA,
    CODIGO_ITEM_CLIENTE,
    UNIDADE_MEDIDA,
    TIPO_FORNECIMENTO,
    ULTIMA_NOTA,
    SERIE_ULTIMA_NOTA,
    DATA_ULTIMA_NOTA,
    TIPO_PROGRAMA,
    CODIGO_CLIENTE,
    NOME_CLIENTE,
    NOME_EMPRESA,
    UNIDADE_EMPRESA,
    NOSSO_CODIGO,
    PRECO_VENDA,
    UND_VENDA)
AS
select a.arquivo, a.codigo_fabrica, a.identificacao_programa, a.data_programa, a.codigo_item_cliente, a.unidade_medida, a.tipo_fornecimento, a.ultima_nota, a.serie_ultima_nota, a.data_ultima_nota, a.tipo_programa, a.codigo_cliente, a.nome_cliente, a.nome_empresa, a.unidade_empresa, a.nosso_codigo, a.preco_venda, a.und_venda
from programa_edi_CODIGO a group by a.arquivo, a.codigo_fabrica, a.identificacao_programa, a.data_programa, a.codigo_item_cliente, a.unidade_medida, a.tipo_fornecimento, a.ultima_nota, a.serie_ultima_nota, a.data_ultima_nota, a.tipo_programa, a.codigo_cliente, a.nome_cliente, a.nome_empresa, a.unidade_empresa, a.nosso_codigo, a.preco_venda, a.und_venda;
--================================================================================================================
/**
    0026
    Status = ok
    *//*View:  CARACTERES_ESPECIAIS*/
CREATE VIEW CARACTERES_ESPECIAIS(
    IDFMEA,
    CE)
AS
SELECT  a.falha_idfmea , (select min(b.falha_caract_esp) from tb_falha_fmea b
where b.falha_caract_esp > 0 and b.falha_idfmea = a.falha_idfmea)
from tb_falha_fmea a where a.falha_caract_esp is not null
and a.falha_caract_esp > 0 group by a.falha_idfmea;
--================================================================================================================
/**
    0027
    Status = ok
    *//*View:  CARACTERES_ESPECIAIS2*/
CREATE VIEW CARACTERES_ESPECIAIS2(
    IDPROC,
    CE)
AS
SELECT a.id_proc  , (select min(b.tipo_caracteristica) from tb_plano b
where b.tipo_caracteristica > 0 and b.id_proc = a.id_proc)
from tb_plano a where a.tipo_caracteristica is not null
and a.tipo_caracteristica > 0
group by a.id_proc;
--================================================================================================================
/**
    0028
    Status = ok
    *//*View:  CENTROS_CUSTO*/
CREATE VIEW CENTROS_CUSTO(
    GRUPO,
    NOME_GRUPO,
    TIPO,
    CENTRO_CUSTO,
    NOME_CENTRO)
AS
select a.idccusto, a.nome, a.tipomo, b.ncc, b.nomesetor  from ccusto a left join tbsetor b
on (a.idccusto = b.idccusto) order by a.idccusto, b.ncc;
--================================================================================================================
/**
    0029
    Status = ok
    *//*View:  CFOP_ESTOQUE*/
CREATE VIEW CFOP_ESTOQUE(
    CFOP,
    CFOPI,
    DESCCFOP,
    MOV_ESTOQUE,
    COD_PARAMETRO,
    DESC_PARAMENTRO,
    FISICO,
    PROCESSO,
    RESERVADO,
    COMPRAS,
    INSPECAO,
    SERVICO)
AS
select tbcfop.cfop, tbcfop.cfopi, tbcfop.desccfop,
case when
tbcfop.movest = 1 then 'N�O'
when TBCFOP.movest = 0 THEN 'SIM'
ELSE 'ND'
END, tbcfop.cod_parametro, tb_parametro_movimentacao.nome_parametro,
tb_parametro_movimentacao.estoque_fisico,
tb_parametro_movimentacao.estoque_processo,
tb_parametro_movimentacao.estoque_reservado,
tb_parametro_movimentacao.estoque_comprado,
tb_parametro_movimentacao.estoque_inspecao,
tb_parametro_movimentacao.estoque_terceiro 
from tbcfop left join tb_parametro_movimentacao 
on (tbcfop.cod_parametro = tb_parametro_movimentacao.cod_parametro)
order by tbcfop.cfopi;
--================================================================================================================
/**
    0030
    Status = ok
    *//*View:  NF_VENDA*/
CREATE VIEW NF_VENDA(
    NUMNF,
    EMISSAO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    DESENHO,
    NUMPED)
AS
select
numnf, emissao, codcli, razao, fantasia, tipo, canc, vend, nomevend, stacom, tbnf.status,
iditemnf, iditemped, codigoitem, tbitensnf.pedidocli, qtdeitem,und, vlunit, vlitem, desenho, numped
from tbnf join tbitensnf on (idnumnf = numnf) WHERE stacom in (0,1) and status > 0 and canc = 'N';
--================================================================================================================
/**
    0031
    Status = ok
    *//*View:  ITENS_FATURADOS*/
CREATE VIEW ITENS_FATURADOS(
    EMISSAO,
    CODIGOITEM,
    NOMEITEM,
    QTDEITEM,
    MES,
    ID)
AS
select emissao, nf_venda.codigoitem, nomeitem, qtdeitem, f_padleft(f_month(emissao),'0',2) || '/' ||  f_year(emissao), f_padleft(f_month(emissao),'0',2) || '/' ||  f_year(emissao)||nf_venda.codigoitem 
from nf_venda left join tbitens on (nf_venda.codigoitem = tbitens.codigoitem)
where emissao > '01.07.2009' and nf_venda.codigoitem <> '4080' and f_year(emissao) = '2009';
--================================================================================================================
/**
    0032
    Status = ok
    *//*View:  CODIGOS_FATURADOS*/
CREATE VIEW CODIGOS_FATURADOS(
    CODIGOITEM,
    NOMEITEM,
    QTDE_TOTAL,
    MES,
    ID)
AS
select codigoitem, nomeitem, sum(qtdeitem), mes, ID
from itens_faturados
group by  codigoitem, nomeitem, mes , ID;
--================================================================================================================
/**
    0033
    Status = ok
    *//*View:  COMPARATIVO_NFE_REC*/
CREATE VIEW COMPARATIVO_NFE_REC(
    BOLDCRON_RAZAO,
    BOLDCRON_CNPJ,
    BOLDCRON_NUMERO_NF,
    BOLDCRON_ENTRADA,
    BOLDCRON_VALOR,
    ADI_RAZAO,
    ADI_CNPJ,
    ADI_NUMERO_NF,
    ADI_ENTRADA,
    ADI_VALOR)
AS
select tb_nfe_recebida.razao_social, tb_nfe_recebida.cnpj, numero_nf, data, valor, TBNFC.razao,
tbnfc.cnpjcli, tbnfc.pedidocli , tbnfc.sistema,tbnfc.valortotalnf 
from tb_nfe_recebida left join tbnfc on (tb_nfe_recebida.cnpj = tbnfc.cnpjcli and
tb_nfe_recebida.numero_nf = tbnfc.pedidocli)
order by numero_nf;
--================================================================================================================
/**
    0034
    Status = ok
    *//*View:  COMPARATIVO_NFE_REC2*/
CREATE VIEW COMPARATIVO_NFE_REC2(
    BOLDCRON_RAZAO,
    BOLDCRON_CNPJ,
    BOLDCRON_NUMERO_NF,
    BOLDCRON_ENTRADA,
    BOLDCRON_VALOR,
    ADI_TIPO_DOC,
    ADI_RAZAO,
    ADI_CNPJ,
    ADI_NUMERO_NF,
    ADI_ENTRADA,
    ADI_VALOR)
AS
select tb_nfe_recebida.razao_social, tb_nfe_recebida.cnpj, numero_nf, data, valor,tbnfc.tipo_doc,  TBNFC.razao,
tbnfc.cnpjcli, tbnfc.pedidocli , tbnfc.sistema,tbnfc.valortotalnf 
from tbnfc left join tb_nfe_recebida on (tbnfc.cnpjcli = tb_nfe_recebida.cnpj and
tbnfc.pedidocli = tb_nfe_recebida.numero_nf) where tbnfc.tipo_doc in ('NFE_DANFE','NFE_XML')
order by numero_nf;
--================================================================================================================
/**
    0035
    Status = ok
    *//*View:  COMPOSICAO_PRODUTO*/
CREATE VIEW COMPOSICAO_PRODUTO(
    PAI,
    NOME,
    FILHO,
    NOME_FILHO,
    QTD,
    UND,
    TIPOITEM,
    MEDIDAS,
    DESENHOITEM)
AS
select a.codigoitem,
case
when f_stringlength(a.refitem) > 1 then a.nomeitem || ' (' || a.refitem || ')'
else a.nomeitem 
end
,   b.codigoitem,
b.descricaoitem,
b.consumo, b.undinf, c.tipoitem,
CASE WHEN C.comprimitem IS NOT null
then '  '
ELSE 'COMP. ' || C.comprimitem
END
||
CASE WHEN C.larguraitem IS null THEN
'  ' ELSE
' LARG. ' || C.larguraitem
END
||
CASE WHEN C.espessuraitem IS NULL THEN
'  ' ELSE
' ESP. ' || C.espessuraitem
END, a.desenhoitem
from tbitens a left join (tbarvoremat b left join tbitens c on (b.codigoitem = c.codigoitem))  on (a.arvore = b.arvore)
where a.tipoitem in ('PRODUTO ACABADO','COMPONENTE FABRICADO') ORDER BY a.codigoitem;
--================================================================================================================
/**
    0036
    Status = ok
    *//*View:  EVENTOS*/
CREATE VIEW EVENTOS(
    ID_EVENTO,
    ID_FATURA,
    ID_PARAMETRO,
    VALOR_INFORMADO,
    NOME_EVENTO,
    CODFORCLI,
    TBFORRAZ,
    TIPO,
    TIPO_EV,
    DOCTO,
    CODDESP,
    DATAVENC,
    DATAPGTO,
    VALORPGTO,
    DESCCONTA,
    EMISSAO)
AS
select TB_EVENTOS_FATURA.ID_EVENTO, ID_FATURA, ID_PARAMETRO, VALOR_INFORMADO, tb_eventos_fatura.nome_evento  ,
CODFORCLI, TBFORRAZ, pagrec.TIPO, tb_parametros_eventos.tipo_evento,   DOCTO, CODDESP, DATAVENC, DATAPGTO, VALORPGTO, DESCCONTA, pagrec.dataemiss from tb_eventos_fatura
left join pagrec on (id_fatura = pagrec.idpagrec)
left join tbfor on (codforcli = tbfor.tbforcod)
LEFT JOIN tb_parametros_eventos ON (tb_eventos_fatura.id_parametro = tb_parametros_eventos.id_evento);
--================================================================================================================
/**
    0037
    Status = ok
    *//*View:  TOTAIS_EVENTOS_FATURA*/
CREATE VIEW TOTAIS_EVENTOS_FATURA(
    ID_FATURA,
    VALOR_INFORMADO)
AS
select id_fatura, sum(valor_informado)
from tb_eventos_fatura
group by id_fatura;
--================================================================================================================
/**
    0038
    Status = ok
    *//*View:  VERFATURA*/
CREATE VIEW VERFATURA(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    ESTAGIO,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    HIST,
    VALORDOC,
    NATUREZADOC,
    CODDESP,
    DATAPGTO,
    VALORPGTO,
    MESBASE,
    MESCOMP,
    PORCJUROS,
    PORCIR,
    PORCINSS,
    PORCDESC,
    VALJURO,
    VALIR,
    VALINSS,
    VALDESC,
    CARTEIRA,
    BANCO,
    IDMOV,
    STATUS,
    ULTREV,
    ALTPOR,
    GERADO,
    FORMPAG,
    REG,
    FLAG,
    SALDO,
    NOMECONTA,
    EXTENSO,
    PEDIDOS,
    NOMEBANCO,
    ENTRADA,
    RECEBER,
    PAGAR,
    PAGO,
    PENDENTE,
    EVENTO_FATURA,
    ENDERECO,
    BAIRRO,
    CIDADE,
    UF,
    AGENCIA,
    CONTA,
    INCLUI_FLUXO,
    INCLUI_NAO_PAGAS)
AS
select idpagrec, dataemiss, descr, tipo, codforcli, estagio, docto, seqdoc, totseqdoc,

case when cartorio
is not null then cartorio
else
datavenc
end , hist,
valordoc , naturezadoc, coddesp, datapgto,
valorpgto, mesbase, mescomp, porcjuros, porcir, porcinss, porcdesc, valjuro, valir, valinss, valdesc, carteira, banco, idmov, status, pagrec.ultrev, altpor, gerado, formpag, reg, flag,

saldo,pagrec.descconta, extenso, pedidos, tbbancos.nomebanco, pagrec.entrada,
CASE WHEN TIPO = 0 THEN valordoc
WHEN TIPO = 2 THEN valordoc
else
0
END,
CASE WHEN TIPO = 1 THEN valordoc * -1
WHEN TIPO = 3 THEN valordoc * -1
else
0
END,
CASE WHEN TIPO = 1 THEN valorpgto * -1
WHEN TIPO = 0 THEN valorpgto
WHEN TIPO = 2 THEN valorpgto
WHEN TIPO = 3 THEN valorpgto * -1
else
0
END,
CASE WHEN TIPO = 1 THEN saldo * -1
WHEN TIPO = 0 THEN saldo
WHEN TIPO = 2 THEN saldo
WHEN TIPO = 3 THEN saldo * -1
else
0
END,
case when totais_eventos_fatura.valor_informado is null
then 0
else totais_eventos_fatura.valor_informado
end, tbbancos.endereco , tbbancos.bairro, tbbancos.cidade, tbbancos.uf, tbbancos.agencia, tbbancos.numconta, contas.inclui_fluxo,
case
WHEN pagrec.saldo = 0 and pagrec.valorpgto = 0 and pagrec.datapgto is not null
then 1
else 0
end
from pagrec left join tbbancos on (pagrec.banco = tbbancos.idbanco)
left join totais_eventos_fatura on (pagrec.idpagrec = totais_eventos_fatura.id_fatura)
left join contas on (pagrec.coddesp = contas.codconta);
--================================================================================================================
/**
    0039
    Status = ok
    *//*View:  VMOV*/
CREATE VIEW VMOV(
    IDMOV,
    DATAMOV,
    DESCMOV,
    IDBANCO,
    VALOR,
    TIPO,
    MEIOPGTO,
    CHEQUE,
    OBS,
    ENTRADA,
    SAIDA,
    SALDO,
    REGBANCO,
    NOMEBANCO,
    CODIGOBANCO,
    AGENCIA,
    NUMCONTA,
    TIPOCONTA,
    FATURAS,
    LOTE_BANCO,
    COD_FINANCEIRO)
AS
select idmov, datamov, descmov,movimento_fin.idbanco,  valor, tipo, meiopgto,cheque, obs, entrada, saida, saldo, regbanco, nomebanco,codigobanco, agencia, numconta, tipoconta,
case when movimento_fin.faturas is null then 0
else movimento_fin.faturas
end, lote_banco, '' from movimento_fin left join tbbancos  on (movimento_fin.idbanco = tbbancos.idbanco) order by datamov;
--================================================================================================================
/**
    0040
    Status = ok
    *//*View:  LANCAMENTOS_EVENTOS*/
CREATE VIEW LANCAMENTOS_EVENTOS(
    ORDEM,
    IDMOV,
    LOTE_BANCO,
    IDFATURA,
    DATAMOV,
    DESCMOV,
    IDBANCO,
    VALOR,
    DOCTO,
    TIPO,
    MEIOPGTO,
    CHEQUE,
    NOMEBANCO,
    CODIGOBANCO,
    AGENCIA,
    NUMCONTA,
    CODCLI,
    NOME,
    COD_FINANCEIRO)
AS
select
1,
verfatura.idmov, vmov.lote_banco,
verfatura.idpagrec,
VERFATURA.datapgto,
nome_evento,
banco,
case when eventos.tipo_ev = 0 then
valor_informado * - 1
else
valor_informado
end
, verfatura.docto,
EVENTOS.tipo,
VERFATURA.formpag,
VMOV.cheque,
verfatura.nomebanco,
vmov.codigobanco,
vmov.agencia,
vmov.numconta, verfatura.codforcli, verfatura.descr, verfatura.coddesp
from verfatura left join vmov on (verfatura.idmov = vmov.idmov)
left join EVENTOS ON (VERFATURA.idpagrec = EVENTOS.id_fatura)
where verfatura.datapgto is not null
order by idmov;
--================================================================================================================
/**
    0041
    Status = ok
    *//*View:  LANCAMENTOS_FATURA*/
CREATE VIEW LANCAMENTOS_FATURA(
    ORDEM,
    IDMOV,
    LOTE_BANCO,
    IDFATURA,
    DATAMOV,
    DESCMOV,
    IDBANCO,
    VALOR,
    DOCTO,
    TIPO,
    MEIOPGTO,
    CHEQUE,
    NOMEBANCO,
    CODIGOBANCO,
    AGENCIA,
    NUMCONTA,
    CODCLI,
    NOME,
    COD_FINANCEIRO)
AS
select
2,
verfatura.idmov, vmov.lote_banco,
verfatura.idpagrec,
datapgto,
descr,
banco,
valordoc, verfatura.docto,
verfatura.tipo,
formpag,
cheque,
verfatura.nomebanco,
vmov.codigobanco,
vmov.agencia,
vmov.numconta, verfatura.codforcli, verfatura.descr, verfatura.coddesp
from verfatura left join vmov on (verfatura.idmov = vmov.idmov)
where verfatura.datapgto is not null
order by idmov;
--================================================================================================================
/**
    0042
    Status = ok
    *//*View:  LANCAMENTOS_FIN*/
CREATE VIEW LANCAMENTOS_FIN(
    ORDEM,
    IDMOV,
    LOTE_BANCO,
    IDFATURA,
    DATAMOV,
    DESCMOV,
    IDBANCO,
    VALOR,
    DOCTO,
    TIPO,
    MEIOPGTO,
    CHEQUE,
    NOMEBANCO,
    CODIGOBANCO,
    AGENCIA,
    NUMCONTA,
    CODCLI,
    NOME,
    COD_FINANCEIRO)
AS
select 3, VMOV.idmov, lote_banco,0, datamov, descmov, VMOV.idbanco, valor * -1, '', VMOV.tipo, VMOV.meiopgto, cheque, nomebanco, codigobanco, agencia, numconta, '',
'', vmov.cod_financeiro 
from vmov;
--================================================================================================================
/**
    0043
    Status = ok
    *//*View:  CONCILIACAO_BANCARIA*/
CREATE VIEW CONCILIACAO_BANCARIA(
    IDMOV,
    LOTE_BANCO,
    ORDEM,
    IDFATURA,
    DATAMOV,
    DESCMOV,
    IDBANCO,
    VALOR,
    DOCTO,
    TIPO,
    MEIOPGTO,
    CHEQUE,
    NOMEBANCO,
    CODIGOBANCO,
    AGENCIA,
    NUMCONTA,
    CODCLI,
    NOME,
    COD_FINANCEIRO)
AS
select idmov, lote_banco, ORDEM,idfatura, datamov, descmov, idbanco, valor,docto, tipo, meiopgto, cheque, nomebanco, codigobanco, agencia, numconta, codcli, nome, cod_financeiro
from lancamentos_FIN
UNION all 
select idmov,lote_banco, ORDEM,idfatura, datamov, descmov, idbanco, valor,docto, tipo, meiopgto, cheque, nomebanco, codigobanco, agencia, numconta, codcli, nome, cod_financeiro
from lancamentos_FATURA
UNION ALL
select idmov,lote_banco, ORDEM, idfatura, datamov, descmov, idbanco, valor,docto, tipo, meiopgto, cheque, nomebanco, codigobanco, agencia, numconta, codcli, nome, cod_financeiro
from lancamentos_EVENTOS;
--================================================================================================================
/**
    0044
    Status = ok
    *//*View:  CONCILIACAO_BANCARIA*/
CREATE VIEW CONS_FMEA(
    PRODUTO,
    DATA_FMEA,
    ANO_MODELO_PROG,
    RESPONSABILIDADE,
    EQUIPE_CENTRAL,
    ELABORACAO,
    TIPO_FMEA,
    DATA_REVISAO,
    APLIC_CODIGO,
    APLIC_IDFMEA,
    IDPROC,
    FUNCAO_OPERACAO,
    FUNCAO_DESCRICAO,
    IDFEMEA,
    DATA_CHAVE,
    FUNCAO_OBJETIVO,
    FALHA_ID,
    FALHA_IDFMEA,
    FALHA_DESCRICAO,
    FALHA_CARACTERISTICA,
    FALHA_ITEM,
    FALHA_CARACT_ESP,
    EFEITO_ID,
    EFEITO_FALHA_ID,
    EFEITO_DESCRICAO,
    EFEITO_SEVERIDADE,
    EFEITO_CLASS,
    EFEITO_ID_FMEA,
    CAUSA_ID,
    CAUSA_EFEITO_ID,
    CAUSA_DESCRICAO,
    CAUSA_OCORRENCIA,
    CAUSA_DETECCAO,
    CAUSA_NPR,
    CAUSA_ID_FMEA,
    CONTROLE_ID,
    CONTROLE_CAUSA_ID,
    CONTROLE_PREVENCAO,
    CONTROLE_DETECCAO,
    CONTROLE_ID_FMEA,
    ACAO_ID,
    ACAO_CONTROLE_ID,
    ACAO_RECOMENDADA,
    ACAO_RESPONSAVEL,
    ACAO_PRAZO,
    ACAO_ADOTADA,
    ACAO_DATAEFETIVA,
    ACAO_SEVERIDADE,
    ACAO_OCORRENCIA,
    ACAO_DETECCAO,
    ACAO_NPR,
    ACAO_ID_FMEA,
    ARVORE)
AS
select tb_fmea_info.produto, tb_fmea_info.data_fmea, tb_fmea_info.ano_modelo_prog, tb_fmea_info.responsabilidade, tb_fmea_info.equipe_central, tb_fmea_info.elaboracao, tb_fmea_info.tipo_fmea, tb_fmea_info.data_revisao,
aplic_codigo, aplic_idfmea, tb_aplicacao_fmea.aplic_idproc,tbarvoreproc.seq , tbarvoreproc.descroper, tbarvoreproc.roteiro,
data_chave, funcao_objetivo,
falha_id, falha_idfmea, falha_descricao, falha_caracteristica, falha_item, falha_caract_esp,
efeito_id, efeito_falha_id, efeito_descricao, efeito_severidade, efeito_class, efeito_id_fmea,
causa_id, causa_efeito_id, causa_descricao, causa_ocorrencia, causa_deteccao, causa_npr, causa_id_fmea,
controle_id, controle_causa_id, controle_prevencao, controle_deteccao, controle_id_fmea,
acao_id, acao_controle_id, acao_recomendada, acao_responsavel, acao_prazo, acao_adotada, acao_dataefetiva, acao_severidade, acao_ocorrencia, acao_deteccao, acao_npr, acao_id_fmea,
tbarvoreproc.arvore
from tb_fmea_info left join
(tb_aplicacao_fmea left join
(tbarvoreproc left join tb_funcao_fmea on (tbarvoreproc.roteiro = tb_funcao_fmea.idfemea)
left join (tb_falha_fmea left join (tb_efeito_fmea left join
(tb_causa_fmea left join (tb_controle_fmea left join tb_acao_fmea on (tb_controle_fmea.controle_id = tb_acao_fmea.acao_controle_id))
on (tb_causa_fmea.causa_id = tb_controle_fmea.controle_causa_id))
on (tb_efeito_fmea.efeito_id = tb_causa_fmea.causa_efeito_id)) on (tb_falha_fmea.falha_id = tb_efeito_fmea.efeito_falha_id))
on (tbarvoreproc.roteiro = tb_falha_fmea.falha_idfmea)
)
on (tb_aplicacao_fmea.aplic_idproc = tbarvoreproc.idarvproc))
on (tb_fmea_info.produto = tb_aplicacao_fmea.aplic_codigo)  where tbarvoreproc.roteiro > 0 order by aplic_idproc;
--================================================================================================================
/**
    0045
    Status = ok
    *//*View:  CONSULTA_CEPS*/
CREATE VIEW CONSULTA_CEPS(
    ENDERECO_CEP,
    ENDERECO_LOGRADOURO,
    CIDADE_DESCRICAO,
    UF_SIGLA,
    CIDADE_CODIGO,
    BAIRRO_DESCRICAO)
AS
select
tb_cep.zcep, tb_cep.zendereco, tb_cep.zmunicipio, tb_cep.zestado ,
tb_cep.zcod_municipio, tb_cep.zbairro from tb_cep;
--================================================================================================================
/**
    0046
    Status = ok
    *//*View:  CONSUMO_CF*/
CREATE VIEW CONSUMO_CF(
    VAR_ARVORE,
    VAR_PRODUTO,
    VAR_CODIGOITEM,
    VAR_CONSUMO,
    VAR_DESCRICAOITEM,
    VAR_LOTE,
    VAR_SALDOLOTE,
    VAR_PROCESSO,
    VAR_SITUACAO,
    VAR_ENTRADA,
    VAR_PROGRAMA,
    VAR_LOCAL)
AS
select tbarvoremat.arvore,  tbarvoremat.produto, tbarvoremat.codigoitem, consumo, descricaoitem, TB_OS.numero_os , 0, TB_OS.saldo + TB_OS.total_terceiro,
TB_OS.status,
TB_OS.data,
f_truncate(cast((TB_OS.saldo + TB_OS.total_terceiro) / consumo as numeric(15,0)))-1, ''
from tbarvoremat left join tb_OS on (tbarvoremat.codigoitem = TB_OS.produto)
where (TB_OS.saldo + TB_OS.total_terceiro) > 0 and tbarvoremat.calculo = 'SEMI-ACABADO'
order by tbarvoremat.codigoitem, tb_os.numero_os;
--================================================================================================================
/**
    0047
    Status = ok
    *//*View:  CONSUMO_ESTOQUE*/
CREATE VIEW CONSUMO_ESTOQUE(
    EMISSAO,
    CODIGOITEM,
    QTDEITEM,
    UND,
    QTDE_PECAS)
AS
select movimento.datalanc, movimento.codigomat, movimento.qtdsaida, movimento.und, sum(movimento.qtdsaida)
from movimento where movimento.grupo = 2
group by movimento.datalanc, movimento.codigomat, movimento.qtdsaida, movimento.und
order by movimento.datalanc;
--================================================================================================================
/**
    0048
    Status = ok
    *//*View:  NOTAS*/
CREATE VIEW NOTAS(
    NUMNF,
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    VALORICMS,
    VALORIPI,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    N_OS,
    N_OS2,
    N_OS3,
    N_OS4,
    QT_OS,
    QT_OS2,
    QT_OS3,
    QT_OS4,
    VLITEMIPI,
    IPI,
    ICMS,
    DESENHO,
    NUMPED,
    FCONV,
    STACOM,
    COMPLEM,
    NOTA,
    UNIDADE,
    NF_NUMERO,
    CHAVE_ACESSO,
    ARVORE,
    TIPOITEM)
AS
select
numnf, emissao, codcli,NFCFOPI,CFOP,DESCCFOP, tbfor.tbforraz , tbfor.tbforfan ,VALORTOTALNF,TBNF.valoricms, TBNF.valoripi, tipo, canc, vend, TBNF.status, NOMEVEND,
iditemnf, iditemped, tbitensnf.codigoitem,tbitens.nomeitem, tbitensnf.pedidocli, qtdeitem,und, vlunit, vlitem,n_os, n_os2, n_os3, n_os4, QT_OS, QT_OS2, QT_OS3, QT_OS4,
tbitensnf.vlipi,IPI,TBNF.icms , tbitens.desenhoitem , numped, FCONV, STACOM, tbitensnf.textolegal, tipos_saidas.nota , tbnf.unidade, nf_numero, tbnf.chave_acesso, tbitens.arvore, tbitens.tipoitem
from tbnf join tipos_saidas join tbitensnf on(tbnf.stacom = tipos_saidas.id) on (idnumnf = numnf) left join tbitens on (tbitensnf.codigoitem = tbitens.codigoitem)
left join tbfor on (tbfor.tbforcod = tbnf.codcli);
--================================================================================================================
/**
    0049
    Status = ok
    *//*View:  CONSUMO_MEDIO*/
CREATE VIEW CONSUMO_MEDIO(
    EMISSAO,
    CODIGOITEM,
    QTDEITEM,
    UND,
    FCONV,
    QTDE_PECAS,
    STACOM)
AS
select emissao, codigoitem, qtdeitem, und, fconv, sum(qtdeitem * fconv), stacom
from notas
group by emissao, codigoitem, qtdeitem, und, fconv, stacom
order by emissao;
--================================================================================================================
/**
    0050
    Status = ok
    *//*View:  CONSUMO_MP*/
CREATE VIEW CONSUMO_MP(
    VAR_ARVORE,
    VAR_PRODUTO,
    VAR_CODIGOITEM,
    VAR_CONSUMO,
    VAR_DESCRICAOITEM,
    VAR_LOTE,
    VAR_SALDOLOTE,
    VAR_PROCESSO,
    VAR_SITUACAO,
    VAR_ENTRADA,
    VAR_PROGRAMA,
    VAR_LOCAL)
AS
select tbarvoremat.arvore,  produto, tbarvoremat.codigoitem, consumo, descricaoitem, lote, saldolote, 0,
case
when f_rtrim(tblote.posicao) = 'PENDENTE' THEN 'AG.INSPE��O'
WHEN f_rtrim(tblote.posicao) = 'A' THEN 'LIBERADO'
WHEN f_rtrim(tblote.posicao) = 'AC' THEN 'SOB DESVIO'
ELSE 'N�O UTILIZ�VEL'
END,
entrada,
f_truncate(cast(saldolote / consumo as numeric(15,0)))-1, tblote.local
from tbarvoremat left join tblote on (tbarvoremat.codigoitem = tblote.codigoitem)
where tblote.saldolote > 0 and tblote.tipo = 0 /* and tbarvoremat.calculo <> 'S/CALCULO_MAT' */
order by tbarvoremat.codigoitem, tblote.lote;
--================================================================================================================
/**
    0060
    Status = ok
    *//*View:  CONSUMO_OS*/
CREATE VIEW CONSUMO_OS(
    VAR_ARVORE,
    VAR_PRODUTO,
    VAR_CODIGOITEM,
    VAR_CONSUMO,
    VAR_DESCRICAOITEM,
    VAR_LOTE,
    VAR_SALDOLOTE,
    VAR_PROCESSO,
    VAR_SITUACAO,
    VAR_ENTRADA,
    VAR_PROGRAMA,
    VAR_LOCAL)
AS
select var_arvore, var_produto, var_codigoitem, var_consumo, var_descricaoitem, var_lote, var_saldolote, var_processo, var_situacao, var_entrada, var_programa, var_local
from consumo_mp union all
select var_arvore, var_produto, var_codigoitem, var_consumo, var_descricaoitem, var_lote, var_saldolote, var_processo, var_situacao, var_entrada, var_programa, var_local
from consumo_cf;
--================================================================================================================
/**
    0061
    Status = ok
    *//*View:  COTACAO*/
CREATE VIEW COTACAO(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    UND,
    DESENHOITEM,
    SITUACAO,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB)
AS
select
NUMPED, CODCLI, tbfor.tbforfan , CPAG, tbfor.TBFORENDER, tbfor.TBFORBAIRRO, tbfor.TBFORCEP, tbfor.TBFORCID, tbfor.TBFOREST, tbfor.TBFORENDERCOB, tbfor.TBFORBAIRROCOB, tbfor.TBFORCEPCOB, tbfor.TBFORCIDCOB, tbfor.TBFORESTCOB, tbfor.TBFORENDERENT, tbfor.TBFORBAIRROENT, tbfor.TBFORCEPENT, tbfor.TBFORCIDENT, tbfor.TBFORESTENT, tbprop.TBFORCODTRANSP, tbprop.TBFORNOMETRANSP,
CFOP, DESCCFOP, COMISSAOVEN, COMISSAOREP, COMISSAOINT, COMISSAOEXT, OBSPED, ENTRADA, TBPROP.ICMS, TBPROP.TF,CONTATO,APROVACAO,
VEND, NOMEVEND, IMPOSTOS, PRAZOCOT, VALIDADECOT, PRIPED, OBSCOT, DEPARTAM, tbfor.tbforraz ,
IDITEM, IDNUMPED, CODPROD, NOMEPROD, DESCORCAM, QTDEPED, QTDEENT, QTDECANC, VLUNIT, VLITEM, IPI, SALDO, VLFATURAR, PRAZO, PCP, PRAZOPCP, POSICAO, OPNUM, PEDIDOCLI,UND, DESENHOITEM,
case TBPROP.status
when 0 THEN 'COTA��O ABERTA'
WHEN 1 THEN 'COTA��O FECHADA'
WHEN 2 THEN 'PEDIDO ABERTO'
WHEN 3 THEN 'PEDIDO FECHADO' ELSE 'COTA��O ABERTA '
end, codigo_municipio, codigo_uf, endereco_numero, tbfor.complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob
from TBPROP LEFT join TBPROPITEM  on (TBPROP.numped = TBPROPITEM.idnumped)
left join tbfor on (tbprop.codcli = tbfor.tbforcod);
--================================================================================================================
/**
    0062
    Status = ok
    *//*View:  COTACAO2*/
CREATE VIEW COTACAO2(
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    ICMS,
    IPI,
    TF,
    SALDO,
    VLFATURAR,
    PRAZO,
    STATUS,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    UND,
    DESENHOITEM,
    REVDESENHOITEM,
    OSNUM,
    OSIDITEM,
    OSIDNUMPED,
    COMP,
    LARG,
    ALT,
    ESP,
    DIAMETRO,
    ITEMNOVO,
    QTDECORES,
    COR1,
    COR2,
    COR3,
    COR4,
    COR5,
    COR6,
    CANTOS,
    QTDEFURO1,
    DIAMFURO1,
    QTDEFURO2,
    DIAMFURO2,
    QTDEFURO3,
    DIAMFURO3,
    QTDEFURO4,
    DIAMFURO4,
    QTDEFURO5,
    DIAMFURO5,
    QTDEFURO6,
    DIAMFURO6,
    ADESIVO,
    MASCARA,
    NUMERACAO,
    NUMDE,
    NUMATE,
    TIPONUM,
    ARTEFINAL,
    ENVIARPOR,
    MONTAGEM,
    FACA,
    MATERIAL,
    INFO)
AS
select
  iditem, idnumped, codprod, nomeprod, descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, icms, ipi, tf, saldo, vlfaturar, prazo, status, pcp, tbpropitem.prazopcp , posicao, opnum, pedidocli, und, desenhoitem, revdesenhoitem,
  osnum, osiditem, osidnumped, comp, larg, alt, esp,diametro, itemnovo, qtdecores, cor1, cor2, cor3, cor4, cor5, cor6, cantos, qtdefuro1, diamfuro1, qtdefuro2, diamfuro2, qtdefuro3, diamfuro3, qtdefuro4, diamfuro4, qtdefuro5, diamfuro5, qtdefuro6, diamfuro6, adesivo, mascara, numeracao, numde, numate, tiponum, artefinal, enviarpor, montagem, faca, material, info
from tbpropitem left join tbosgraf on (tbpropitem.iditem = tbosgraf.osiditem);
--================================================================================================================
/**
    0063
    Status = ok
    *//*View:  ESTATISTICA_COTACAO*/
CREATE VIEW ESTATISTICA_COTACAO(
    NUMPED,
    CODCLI,
    NOME_CLIENTE,
    MES_ENTREGA,
    PRAZO_ENTREGA,
    LIBERADO_ENGENHARIA,
    ENVIADO_CLIENTE,
    ST,
    AT_PRAZO_CLIENTE,
    AT_PRAZO_ENG,
    ATRASADAS_ENG,
    ATRASADAS_CLI,
    ANO,
    MES,
    UNIDADE)
AS
select pedido.numped,  pedido.codcli, pedido.fantasia, pedido.mes, pedido.prazo,
pedido.libengeorc, pedido.dataenv, PEDIDO.st,
CASE when
DATAENV <= PRAZO THEN 1
ELSE 0
END,
CASE when
LIBENGEORC <= PRAZO THEN 1
ELSE 0
END ,
CASE WHEN
PRAZO < current_date AND LIBENGEORC IS NULL THEN 1
ELSE 0
END,
CASE WHEN
PRAZO < current_date AND DATAENV IS NULL THEN 1
ELSE 0
END,
f_year(prazo),
f_month(prazo), pedido.unidade 
from pedido
where pedido.st in(1,2,6) and pedido.prazo >= '01.09.2010'
group by numped,pedido.codcli, pedido.fantasia, pedido.mes, pedido.prazo,
pedido.libengeorc, pedido.dataenv, PEDIDO.st,
CASE when
DATAENV <= PRAZO THEN 1
ELSE 0
END,
CASE when
LIBENGEORC <= PRAZO THEN 1
ELSE 0
END,
CASE WHEN
PRAZO < current_date AND LIBENGEORC IS NULL THEN 1
ELSE 0
END,
CASE WHEN
PRAZO < current_date AND DATAENV IS NULL THEN 1
ELSE 0
END,
f_year(prazo),
f_month(prazo), pedido.unidade;
--================================================================================================================
/**
    0064
    Status = ok
    *//*View:  COTACOES_ENVIADAS*/
CREATE VIEW COTACOES_ENVIADAS(
    ANO,
    MES,
    MES_ENTREGA,
    ENVIADAS,
    NO_PRAZO)
AS
select ano, mes, mes_entrega, count(numped), sum(at_prazo_cliente)
from estatistica_cotacao where st = 2 and enviado_cliente is not null
group by ano, mes, mes_entrega;
--================================================================================================================
/**
    0065
    Status = ok
    *//*View:  COTACOES_ENVIADAS_CLIENTE*/
CREATE VIEW COTACOES_ENVIADAS_CLIENTE(
    ANO,
    MES,
    MES_ENTREGA,
    CODCLI,
    NOME_CLIENTE,
    ENVIADAS,
    NO_PRAZO)
AS
select ano, mes, mes_entrega, codcli, nome_cliente, count(numped), sum(at_prazo_cliente)
from estatistica_cotacao where st = 2 and enviado_cliente is not null
group by ano, mes, mes_entrega, codcli, nome_cliente;
--================================================================================================================
/**
    0066
    Status = ok
    *//*View:  COTACOES_ENVIADAS_MET*/
CREATE VIEW COTACOES_ENVIADAS_MET(
    ANO,
    MES,
    MES_ENTREGA,
    ENVIADAS,
    NO_PRAZO)
AS
select ano, mes, mes_entrega, count(numped), sum(at_prazo_cliente)
from estatistica_cotacao where st = 2 and enviado_cliente is not null
and unidade in (1,2)
group by ano, mes, mes_entrega;
--================================================================================================================
/**
    0067
    Status = ok
    *//*View:  COTACOES_ENVIADAS_MET_CLIENTE*/
CREATE VIEW COTACOES_ENVIADAS_MET_CLIENTE(
    ANO,
    MES,
    MES_ENTREGA,
    UNIDADE,
    CODCLI,
    NOME_CLIENTE,
    ENVIADAS,
    NO_PRAZO)
AS
select ano, mes, mes_entrega,unidade, codcli, nome_cliente, count(numped), sum(at_prazo_cliente)
from estatistica_cotacao where st = 2 and enviado_cliente is not null
and unidade in (1,2)
group by ano, mes, mes_entrega,unidade, codcli, nome_cliente;
--================================================================================================================
/**
    0068
    Status = ok
    *//*View:  COTACOES_ENVIADAS_PLA*/
CREATE VIEW COTACOES_ENVIADAS_PLA(
    ANO,
    MES,
    MES_ENTREGA,
    ENVIADAS,
    NO_PRAZO)
AS
select ano, mes, mes_entrega, count(numped), sum(at_prazo_cliente)
from estatistica_cotacao where st = 2 and enviado_cliente is not null
and unidade in (3,4)
group by ano, mes, mes_entrega;
--================================================================================================================
/**
    0069
    Status = ok
    *//*View:  COTACOES_ENVIADAS_PLA_CLIENTE*/
CREATE VIEW COTACOES_ENVIADAS_PLA_CLIENTE(
    ANO,
    MES,
    MES_ENTREGA,
    UNIDADE,
    CODCLI,
    NOME_CLIENTE,
    ENVIADAS,
    NO_PRAZO)
AS
select ano, mes, mes_entrega,unidade, codcli, nome_cliente, count(numped), sum(at_prazo_cliente)
from estatistica_cotacao where st = 2 and enviado_cliente is not null
and unidade in (3,4)
group by ano, mes, mes_entrega,unidade, codcli, nome_cliente;
--================================================================================================================
/**
    0070
    Status = ok
    *//*View:  COTACOES_META_TOTAL*/
CREATE VIEW COTACOES_META_TOTAL(
    META,
    ANO,
    PARAMETRO,
    MES,
    TOTAL)
AS
select b.meta, b.ano, sum(b.parametro), b.mes,
(select sum(parametro) from tb_metas_anuais c where c.ano = b.ano)
from tb_metas_anuais b
group by b.meta, b.ano, b.mes;
--================================================================================================================
/**
    0071
    Status = ok
    *//*View:  PEDIDO_COTADO*/
CREATE VIEW PEDIDO_COTADO(
    NPED,
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    LIBENGEPED,
    LIBENGEORC,
    PEDNOVO,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    UND,
    DESENHOITEM,
    REVDESENHOITEM,
    CODFATURAMITEM,
    SEMANA,
    ANOREF,
    FCVENDA,
    COMPLEMENTO,
    VTOTIPI,
    VORIPI,
    STPREV,
    MES,
    MESBASE,
    CFOPI,
    VLICMS,
    SALDOICMS,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    UNIDADE,
    CRITICO,
    PROB,
    ID_ORIGEM,
    PEDI_ORIGEM)
AS
select
tbprop.nped , numped, codcli, tbfor.tbforfan, cpag, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest, tbfor.tbforendercob, tbfor.tbforbairrocob, tbfor.tbforcepcob, tbfor.tbforcidcob, tbfor.tbforestcob,
tbfor.tbforenderent, tbfor.tbforbairroent, tbfor.tbforcepent, tbfor.tbforcident, tbfor.tbforestent, tbprop.tbforcodtransp, tbprop.tbfornometransp, tbprop.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, tbprop.obsped, entrada, tbprop.icms, tbprop.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, tbfor.tbforraz , tbprop.libengeped, tbprop.libengeorc, TBPROP.pednovo,
iditem, idnumped, tbpropitem.codprod, TBITENS.nomeitem, descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, ipi, saldo, vlfaturar, prazo, pcp, prazopcp, posicao, opnum, pedidocli,und, tbpropitem.desenhoitem, tbpropitem.revdesenhoitem,tbitens.codfaturamitem,  semanaven, anoref, fcvenda ,tbpropitem.complemento,
case (ipi*vlfaturar)
when 0 then 0 else
(ipi*vlfaturar)/100
end,
case (ipi*vlitem)
when 0 then 0 else
(ipi*vlitem)/100
end, tbpropitem.status, upper(f_cmonthshortlang(prazo,'pt') || '/' || anoref), f_padleft(f_month(PRAZO),'0',2)  || '/' || anoref, cfopi,
((TBPROPITEM.vlitem * TBPROP.icms) / 100), ((TBPROPITEM.vlfaturar * TBPROP.icms) / 100)
, codigo_municipio, codigo_uf, endereco_numero, tbfor.complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob,
tbprop.unidade, case
when TBPROPITEM.semanapcp <> '1' THEN 'N�O'
ELSE 'SIM'
END, tbpropitem.ind_prob, tbpropitem.id_origem, tbpropitem.ped_origem 
from tbprop left join tbpropitem left join tbitens  on (tbpropitem.codprod = tbitens.codigoitem)  on (tbprop.numped = tbpropitem.idnumped) left join tbfor on (tbprop.codcli = tbfor.tbforcod)
WHERE TBPROP.status IN (3,4,5) AND TBPROPITEM.ped_origem <> 0;
--================================================================================================================
/**
    0072
    Status = ok
    *//*View:  ORCAMENTO_PREVISTO*/
CREATE VIEW ORCAMENTO_PREVISTO(
    NUMPED,
    IDITEM,
    CODCLI,
    NOME_CLIENTE,
    UNIDADE,
    PROB,
    VLITEM,
    SOP,
    ST,
    MES,
    ANO,
    MOTIVO,
    ID_ORIGEM,
    VLITEM_APROV,
    NUMPED_APROV)
AS
select b.numped, b.iditem,   b.codcli, b.fantasia,b.unidade,  b.prob,
b.vlitem, b.libengeped, b.st,
f_month(b.libengeped), f_year(b.libengeped), b.pednovo, c.id_origem, c.vlitem, c.numped from pedido b
left join pedido_COTADO c on (b.iditem = c.id_origem)
where b.st in (1,2,6) and b.pednovo in (1,2,3,5)
and b.prob >= 8;
--================================================================================================================
/**
    0073
    Status = ok
    *//*View:  COTACOES_GANHAS*/
CREATE VIEW COTACOES_GANHAS(
    ANO,
    MES,
    ORCADO,
    GANHO,
    META)
AS
SELECT c.ano , c.mes, SUM(b.VLITEM), SUM(b.VLITEM_APROV), c.parametro
from cotacoes_meta_total c left join orcamento_previsto b on (c.ano = b.ano and c.mes = b.mes)
group by c.ano, c.mes, c.parametro;
--================================================================================================================
/**
    0074
    Status = ok
    *//*View:  COTACOES_GANHAS_CLIENTE*/
CREATE VIEW COTACOES_GANHAS_CLIENTE(
    ANO,
    CODCLI,
    NOME_CLIENTE,
    ORCADO,
    GANHO,
    META)
AS
SELECT c.ano , b.codcli, b.nome_cliente, SUM(b.VLITEM), SUM(b.VLITEM_APROV), c.total
from cotacoes_meta_total c left join orcamento_previsto b on (c.ano = b.ano and c.mes = b.mes)
where codcli is not null group by c.ano, b.codcli,b.nome_cliente,  c.total;
--================================================================================================================
/**
    0075
    Status = ok
    *//*View:  COTACOES_META*/
CREATE VIEW COTACOES_META(
    META,
    ANO,
    PARAMETRO,
    UNID_NEG,
    MES,
    TOTAL)
AS
select b.meta, b.ano, b.parametro, b.unid_neg, b.mes,
(select sum(parametro) from tb_metas_anuais c where c.ano = b.ano and c.unid_neg = b.unid_neg)
from tb_metas_anuais b;
--================================================================================================================
/**
    0076
    Status = ok
    *//*View:  ORCAMENTO_PREVISTO_MET*/
CREATE VIEW ORCAMENTO_PREVISTO_MET(
    NUMPED,
    IDITEM,
    CODCLI,
    NOME_CLIENTE,
    UNIDADE,
    PROB,
    VLITEM,
    SOP,
    ST,
    MES,
    ANO,
    MOTIVO,
    ID_ORIGEM,
    VLITEM_APROV,
    NUMPED_APROV)
AS
select b.numped, b.iditem,   b.codcli, b.fantasia,b.unidade,  b.prob,
b.vlitem, b.libengeped, b.st,
f_month(b.libengeped), f_year(b.libengeped), b.pednovo, c.id_origem, c.vlitem, c.numped from pedido b
left join pedido_COTADO c on (b.iditem = c.id_origem)
where b.st in (1,2,6) and b.pednovo in (1,2,3,5)
and b.prob >= 8 and b.unidade in (1,2);
--================================================================================================================
/**
    0077
    Status = ok
    *//*View:  COTACOES_GANHAS_MET*/
CREATE VIEW COTACOES_GANHAS_MET(
    ANO,
    MES,
    ORCADO,
    GANHO,
    META)
AS
SELECT c.ano , c.mes, SUM(b.VLITEM), SUM(b.VLITEM_APROV), c.parametro
from cotacoes_meta c left join orcamento_previsto_met b on (c.ano = b.ano and c.mes = b.mes)
where c.unid_neg = '1,2' group by c.ano, c.mes, c.parametro;
--================================================================================================================
/**
    0078
    Status = ok
    *//*View:  COTACOES_GANHAS_MET_CLIENTE*/
CREATE VIEW COTACOES_GANHAS_MET_CLIENTE(
    ANO,
    CODCLI,
    NOME_CLIENTE,
    ORCADO,
    GANHO,
    META)
AS
SELECT c.ano , b.codcli, b.nome_cliente, SUM(b.VLITEM), SUM(b.VLITEM_APROV), c.total
from cotacoes_meta c left join orcamento_previsto_met b on (c.ano = b.ano and c.mes = b.mes)
where c.unid_neg = '1,2'  and codcli is not null group by c.ano, b.codcli,b.nome_cliente,  c.total;
--================================================================================================================
/**
    0079
    Status = ok
    *//*View:  ORCAMENTO_PREVISTO_PLA*/
CREATE VIEW ORCAMENTO_PREVISTO_PLA(
    NUMPED,
    IDITEM,
    CODCLI,
    NOME_CLIENTE,
    UNIDADE,
    PROB,
    VLITEM,
    SOP,
    ST,
    MES,
    ANO,
    MOTIVO,
    ID_ORIGEM,
    VLITEM_APROV,
    NUMPED_APROV)
AS
select b.numped, b.iditem,   b.codcli, b.fantasia,b.unidade,  b.prob,
b.vlitem, b.libengeped, b.st,
f_month(b.libengeped), f_year(b.libengeped), b.pednovo, c.id_origem, c.vlitem, c.numped from pedido b
left join pedido_COTADO c on (b.iditem = c.id_origem)
where b.st in (1,2,6) and b.pednovo in (1,2,3,5)
and b.prob >= 8 and b.unidade in (3,4);



/* View: COTACOES_GANHAS_PLA */
CREATE VIEW COTACOES_GANHAS_PLA(
    ANO,
    MES,
    ORCADO,
    GANHO,
    META)
AS
SELECT c.ano , c.mes, SUM(b.VLITEM), SUM(b.VLITEM_APROV), c.parametro
from cotacoes_meta c left join orcamento_previsto_pla b on (c.ano = b.ano and c.mes = b.mes)
where c.unid_neg = '3,4' group by c.ano, c.mes, c.parametro
;



/* View: COTACOES_GANHAS_PLA_CLIENTE */
CREATE VIEW COTACOES_GANHAS_PLA_CLIENTE(
    ANO,
    CODCLI,
    NOME_CLIENTE,
    ORCADO,
    GANHO,
    META)
AS
SELECT c.ano , b.codcli, b.nome_cliente, SUM(b.VLITEM), SUM(b.VLITEM_APROV), c.total
from cotacoes_meta c left join orcamento_previsto_pla b on (c.ano = b.ano and c.mes = b.mes)
where c.unid_neg = '3,4'  and codcli is not null group by c.ano, b.codcli,b.nome_cliente,  c.total
;



/* View: COTACOES_REALIZADAS */
CREATE VIEW COTACOES_REALIZADAS(
    ANO,
    MES,
    MES_ENTREGA,
    SOLICITADAS,
    REALIZADAS)
AS
select c.ano, c.mes, c.mes_entrega, count(numped),
(SELECT COUNT(NUMPED) FROM ESTATISTICA_COTACAO WHERE (estatistica_cotacao.enviado_cliente IS not NULL and estatistica_cotacao.mes_entrega = c.mes_entrega))
from estatistica_cotacao c where st IN (1,2,6)
group by c.ano, c.mes, c.mes_entrega
;



/* View: COTACOES_REALIZADAS_CLIENTE */
CREATE VIEW COTACOES_REALIZADAS_CLIENTE(
    ANO,
    MES,
    MES_ENTREGA,
    CODCLI,
    NOME_CLIENTE,
    SOLICITADAS,
    REALIZADAS)
AS
select c.ano, c.mes, c.mes_entrega, c.codcli, c.nome_cliente, count(numped),
(SELECT COUNT(NUMPED) FROM ESTATISTICA_COTACAO WHERE (estatistica_cotacao.enviado_cliente IS not NULL and estatistica_cotacao.mes_entrega = c.mes_entrega and estatistica_cotacao.codcli = c.codcli))
from estatistica_cotacao c where st IN (1,2,6)
group by c.ano, c.mes, c.mes_entrega,c.codcli, c.nome_cliente
;



/* View: COTACOES_REALIZADAS_MET */
CREATE VIEW COTACOES_REALIZADAS_MET(
    ANO,
    MES,
    MES_ENTREGA,
    SOLICITADAS,
    REALIZADAS)
AS
select c.ano, c.mes, c.mes_entrega, count(numped),
(SELECT COUNT(NUMPED) FROM ESTATISTICA_COTACAO WHERE (estatistica_cotacao.enviado_cliente IS not NULL and estatistica_cotacao.mes_entrega = c.mes_entrega and estatistica_cotacao.unidade in (1,2)))
from estatistica_cotacao c where st IN (1,2,6)
and c.unidade in (1,2)
group by c.ano, c.mes, c.mes_entrega
;



/* View: COTACOES_REALIZADAS_MET_CLIENTE */
CREATE VIEW COTACOES_REALIZADAS_MET_CLIENTE(
    ANO,
    MES,
    MES_ENTREGA,
    CODCLI,
    NOME_CLIENTE,
    SOLICITADAS,
    REALIZADAS)
AS
select c.ano, c.mes, c.mes_entrega, c.codcli, c.nome_cliente, count(numped),
(SELECT COUNT(NUMPED) FROM ESTATISTICA_COTACAO WHERE (estatistica_cotacao.enviado_cliente IS not NULL and estatistica_cotacao.mes_entrega = c.mes_entrega and estatistica_cotacao.codcli = c.codcli and estatistica_cotacao.unidade in (1,2)))
from estatistica_cotacao c where st IN (1,2,6) and unidade in (1,2)
group by c.ano, c.mes, c.mes_entrega, c.codcli, c.nome_cliente
;



/* View: COTACOES_REALIZADAS_PLA */
CREATE VIEW COTACOES_REALIZADAS_PLA(
    ANO,
    MES,
    MES_ENTREGA,
    SOLICITADAS,
    REALIZADAS)
AS
select c.ano, c.mes, c.mes_entrega, count(numped),
(SELECT COUNT(NUMPED) FROM ESTATISTICA_COTACAO WHERE (estatistica_cotacao.enviado_cliente IS not NULL and estatistica_cotacao.mes_entrega = c.mes_entrega and estatistica_cotacao.unidade in (3,4)))
from estatistica_cotacao c where st IN (1,2,6)
and unidade in (3,4)
group by c.ano, c.mes, c.mes_entrega
;



/* View: COTACOES_REALIZADAS_PLA_CLIENTE */
CREATE VIEW COTACOES_REALIZADAS_PLA_CLIENTE(
    ANO,
    MES,
    MES_ENTREGA,
    CODCLI,
    NOME_CLIENTE,
    SOLICITADAS,
    REALIZADAS)
AS
select c.ano, c.mes, c.mes_entrega, c.codcli, c.nome_cliente, count(numped),
(SELECT COUNT(NUMPED) FROM ESTATISTICA_COTACAO WHERE (estatistica_cotacao.enviado_cliente IS not NULL and estatistica_cotacao.mes_entrega = c.mes_entrega and estatistica_cotacao.codcli = c.codcli and estatistica_cotacao.unidade in (3,4)))
from estatistica_cotacao c where st IN (1,2,6) and unidade in (3,4)
group by c.ano, c.mes, c.mes_entrega, c.codcli, c.nome_cliente
;



/* View: COTCOMPRA */
CREATE VIEW COTCOMPRA(
    IDCOT,
    DATACOT,
    REFCOT,
    CODIGOITEM,
    DESCITEM,
    UNDCOMPRA,
    QTDE,
    PRAZOSOL,
    OPNUM,
    OBSCOT,
    REQUISITANTE,
    SETOR,
    DESTINO,
    NCC,
    IDITEMCOT,
    NIDCOT,
    CODFOR,
    NOMEFOR,
    PRECO,
    PRAZO,
    CONDICOES,
    VALORFRETE,
    OBS,
    APROVACAO,
    APROVADO,
    USERNOME,
    NOMESETOR)
AS
select
a.idcot, a.datacot, a.refcot, a.codigoitem, a.descitem, a.undcompra, a.qtde, a.prazosol, a.opnum, a.obscot, a.requisitante, a.setor, a.destino, a.ncc,
b.iditemcot, b.nidcot, b.codfor, b.nomefor, b.preco, b.prazo, b.condicoes, b.valorfrete, b.obs, b.aprovacao, b.aprovado,
c.usernome, d.nomesetor
from tbcot a left join tbcotitem b on (idcot = nidcot) left join tb_user c on (a.requisitante = c.userid)
left join tbsetor d on (a.setor = d.idsetor)
;



/* View: COTFINAL */
CREATE VIEW COTFINAL(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    UND,
    DESENHOITEM,
    REVDESENHOITEM,
    OSNUM,
    OSIDITEM,
    OSIDNUMPED,
    COMP,
    LARG,
    ALT,
    ESP,
    DIAMETRO,
    ITEMNOVO,
    QTDECORES,
    COR1,
    COR2,
    COR3,
    COR4,
    COR5,
    COR6,
    CANTOS,
    QTDEFURO1,
    DIAMFURO1,
    QTDEFURO2,
    DIAMFURO2,
    QTDEFURO3,
    DIAMFURO3,
    QTDEFURO4,
    DIAMFURO4,
    QTDEFURO5,
    DIAMFURO5,
    QTDEFURO6,
    DIAMFURO6,
    ADESIVO,
    MASCARA,
    NUMERACAO,
    NUMDE,
    NUMATE,
    TIPONUM,
    ARTEFINAL,
    ENVIARPOR,
    MONTAGEM,
    FACA,
    MATERIAL,
    INFO,
    SITUACAO)
AS
select
NUMPED, CODCLI, FANTASIA, CPAG, TBFORENDER, TBFORBAIRRO, TBFORCEP, TBFORCID, TBFOREST, TBFORENDERCOB, TBFORBAIRROCOB, TBFORCEPCOB, TBFORCIDCOB, TBFORESTCOB, TBFORENDERENT, TBFORBAIRROENT, TBFORCEPENT, TBFORCIDENT, TBFORESTENT, TBFORCODTRANSP, TBFORNOMETRANSP,
CFOP, DESCCFOP, COMISSAOVEN, COMISSAOREP, COMISSAOINT, COMISSAOEXT, OBSPED, ENTRADA, TBPROP.ICMS, TBPROP.TF,CONTATO,APROVACAO,
VEND, NOMEVEND, IMPOSTOS, PRAZOCOT, VALIDADECOT, PRIPED, OBSCOT, DEPARTAM, RAZAO,
IDITEM, IDNUMPED, CODPROD, NOMEPROD, DESCORCAM, QTDEPED, QTDEENT, QTDECANC, VLUNIT, VLITEM,cotacao2.ipi,  SALDO, VLFATURAR, PRAZO, PCP, PRAZOPCP, POSICAO, OPNUM, PEDIDOCLI, UND, DESENHOITEM, REVDESENHOITEM, OSNUM, OSIDITEM, OSIDNUMPED, COMP, LARG, ALT, ESP,DIAMETRO, ITEMNOVO, QTDECORES, COR1, COR2, COR3, COR4, COR5, COR6, CANTOS, QTDEFURO1, DIAMFURO1, QTDEFURO2, DIAMFURO2, QTDEFURO3, DIAMFURO3, QTDEFURO4, DIAMFURO4, QTDEFURO5, DIAMFURO5, QTDEFURO6, DIAMFURO6, ADESIVO, MASCARA, NUMERACAO, NUMDE, NUMATE, TIPONUM, ARTEFINAL, ENVIARPOR, MONTAGEM, FACA, MATERIAL, INFO,
case TBPROP.status
when 0 THEN 'COTA��O ABERTA'
WHEN 1 THEN 'COTA��O FECHADA'
WHEN 2 THEN 'PEDIDO ABERTO'
WHEN 3 THEN 'PEDIDO FECHADO' ELSE 'COTAC�O ABERTA '
end
from TBPROP LEFT join COTACAO2  on (TBPROP.numped = COTACAO2.idnumped)
;



/* View: RESERVAS_ESTOQUE */
CREATE VIEW RESERVAS_ESTOQUE(
    DATA,
    STATUS,
    CODIGO,
    OS,
    UND,
    LOTE,
    QTD)
AS
select TB_OS.data, TB_OS.status, codigomat, os, und, lote, sum(movimento.qtdereserv)
from movimento left JOIN tb_os ON (MOVIMENTO.os = TB_OS.numero_os) where movimento.cod_parametro = '03.10' and movimento.datalanc >='01.08.2012'
group by TB_OS.DATA, TB_OS.status , codigomat, os, und, lote, cod_parametro
;



/* View: SAIDAS_ESTOQUE */
CREATE VIEW SAIDAS_ESTOQUE(
    CODIGO,
    OS,
    UND,
    LOTE,
    QTD)
AS
select codigomat, os, und, lote, sum(movimento.qtd_mov)
from movimento where movimento.grupo = 2 and movimento.datalanc >='01.08.2012'
AND MOVIMENTO.os > 0
group by codigomat, os, und, lote, cod_parametro
;



/* View: CRITICA_OS */
CREATE VIEW CRITICA_OS(
    DATA,
    STATUS,
    CODIGO,
    OS,
    UND,
    LOTE,
    RESERVA,
    SAIDA,
    BAIXAR)
AS
select A.data, A.status, a.codigo, a.os, a.und, a.lote, a.qtd,
case when b.qtd is null
then 0 else
b.qtd
end, A.qtd +
(case when b.qtd is null
then 0 else
b.qtd
end)
from reservas_estoque a left join saidas_estoque b
on (a.codigo = b.codigo and a.os = b.os and a.lote=b.lote)
order by a.os,  a.codigo, a.lote
;



/* View: CRONOGRAMA_AUDITORIA_PRODUTO */
CREATE VIEW CRONOGRAMA_AUDITORIA_PRODUTO(
    CODIGO,
    DESCRICAO,
    CLIENTE,
    INCLUSAO,
    ATIVO,
    PRODUZIDO,
    OS,
    DATA_AUDITORIA,
    ID,
    STATUS,
    OBSERVACAO)
AS
select a.codigoitem, a.nomeitem, a.nomeclitem,  a.inclusao,
case when f_daysbetween(current_date, a.dataultvenda)< 365 or
f_daysbetween(current_date, a.dataultcompra)< 365 or f_daysbetween(current_date, a.datarevcnc)< 365 then 'S'
else
'N'
end, a.datarevcnc,
(select max(tb_os.numero_os) from tb_os where tb_os.produto = a.codigoitem),
(select max(tb_auditoria_produto.prazo) from tb_auditoria_produto where tb_auditoria_produto.item = a.codigoitem),
(select max(tb_auditoria_produto.id) from tb_auditoria_produto where tb_auditoria_produto.item = a.codigoitem),
coalesce((select case when b.status = 1 then 'REALIZADA'
WHEN b.status = 0 and b.prazo < current_date  then 'PENDENTE'
WHEN b.status = 0 and b.prazo >= current_date  then 'PROGRAMADA'
ELSE 'AG.PROGRAMA��O'
END
from tb_auditoria_produto b where b.id = (select max(tb_auditoria_produto.id) from tb_auditoria_produto where tb_auditoria_produto.item = a.codigoitem)),'AG.PROGRAMA��O'),
(select
c.observacao
from tb_auditoria_produto c where c.id = (select max(tb_auditoria_produto.id) from tb_auditoria_produto where tb_auditoria_produto.item = a.codigoitem))
from tbitens a where a.tipoitem in ('PRODUTO ACABADO','COMPONENTE FABRICADO') order by a.codigoitem
;



/* View: ULTIMA_PREVENTIVA_FERRAMENTA */
CREATE VIEW ULTIMA_PREVENTIVA_FERRAMENTA(
    CODIGO,
    OM,
    DATA)
AS
select a.codigo, max(a.n_cont), cast(max(a.data_encerrada) as timestamp)
from tb_om a
where a.tipo_manut = 2 and a.natureza_manut = 2 group by codigo
;



/* View: OS_REPORT */
CREATE VIEW OS_REPORT(
    ID,
    USUARIO,
    CODIGO,
    NIVEL,
    NOME,
    SEQ,
    COMPONENTE,
    CONSUMO_UNIT,
    CONSUMO_TOT,
    SETOR,
    NOME_SETOR,
    PCS_HORA,
    SETUP_HORA,
    CARGA_HS,
    ARVORE,
    PRODUTO,
    NOME_PRODUTO,
    TIPO_EST,
    UND,
    LOTE,
    IDPROC,
    IDMAT,
    UND_POR,
    TIPOMP,
    CALCULO,
    VR_UNIT,
    CUSTO_MAT,
    CUSTO_TRAT,
    CUSTO_PROC_MAQ,
    CUSTO_PROC_MO,
    CUSTO_APOIO,
    CUSTO_ITEM,
    CUSTO_IMPORT_ITEM,
    CUSTO_ACUM,
    CONSUMO_EXEC,
    CONSUMO_CANC,
    CONSUMO_SALDO,
    CONSUMO_RES,
    CONSUMO_REQ,
    REQ_N,
    DATA_INICIO,
    DATA_TERMINO,
    CARGA_EXEC,
    CARGA_SALDO,
    OBS_MAT,
    OBS_PROC,
    N_OS,
    REC_1,
    REC_2,
    REC_3,
    CUSTO_OPER,
    CUSTO_OS,
    CUSTO_REAL,
    PEDCOMPRA_N,
    STATUS_OS,
    DATA_INC,
    DATA_LIB,
    DATA_PROD,
    DATA_FAT,
    TIPO_OS,
    PED_VENDA,
    ID_PED_VENDA,
    IDPAI,
    CODIGO_CLIENTE,
    NOME_CLIENTE,
    DESENHOITEM,
    DESCROPER,
    OBS,
    NOMEREC,
    QTDE_PRODUZIDA)
AS
select  a.id, a.usuario, a.codigo, a.nivel, a.nome, a.seq, a.componente, a.consumo_unit, a.consumo_tot, a.setor, a.nome_setor, d.pchora, d.setpeca,
case when d.pchora > 0 then
(a.lote/d.pchora)+(d.setpeca/60)
else 0
end
,
a.arvore, a.produto, a.nome_produto, a.tipo_est, a.und, a.lote, a.idproc, a.idmat, a.und_por, a.tipomp, a.calculo, a.vr_unit, a.custo_mat, a.custo_trat, a.custo_proc_maq, a.custo_proc_mo, a.custo_apoio, a.custo_item, a.custo_import_item, a.custo_acum, a.consumo_exec, a.consumo_canc, a.consumo_saldo, a.consumo_res, a.consumo_req, a.req_n, a.data_inicio, a.data_termino, a.carga_exec, a.carga_saldo, a.obs_mat, a.obs_proc, a.n_os, a.rec_1, a.rec_2, a.rec_3, a.custo_oper, a.custo_os, a.custo_real, a.pedcompra_n, a.status_os, a.data_inc, a.data_lib, a.data_prod, a.data_fat, a.tipo_os, a.ped_venda, a.id_ped_venda, a.idpai,
b.codigo_cliente, b.nome_cliente, c.desenhoitem, d.descroper, d.obs  , e.nomerec, CAST(B.total_produzido AS DOUBLE precision)
from estrut_os a left join tb_os b on (a.n_os = b.numero_os)
left join tbitens c on (a.produto = c.codigoitem)
left join tbarvoreproc d on (a.idproc = d.idarvproc)
left join tbrecurso e on (a.rec_1 = e.idrec)
order by a.seq
;



/* View: MANUTENCAO_FERRAMENTA */
CREATE VIEW MANUTENCAO_FERRAMENTA(
    CODIGO,
    DESCRICAO,
    MANUT_PECAS,
    MANUT_DIAS,
    ULTIMA_MANUT,
    OM,
    QTDE_PRODUZIDA,
    POR_DATA)
AS
select a.codigoitem, a.nomeitem, a.manut_pecas, a.manut_dias,
cast (b.data as timestamp), b.om,
(select sum(c.qtde_produzida) from os_report c where c.tipomp = 'FERRAMENTAS' AND c.data_inc > b.data AND C.codigo = A.codigoitem),
 addday(cast (b.data as timestamp), a.manut_dias)
from tbitens a left join ultima_preventiva_ferramenta b on
a.codigoitem = b.codigo
where a.tipoitem = 'FERRAMENTAS' and a.manut_dias > 0
;



/* View: CRONOGRAMA_FERRAMENTAL */
CREATE VIEW CRONOGRAMA_FERRAMENTAL(
    CODIGO,
    DESCRICAO,
    MANUT_PECAS,
    MANUT_DIAS,
    ULTIMA_MANUT,
    OM,
    QTDE_PRODUZIDA,
    PROXIMA_MANUTENCAO)
AS
select a.codigo, a.descricao, a.manut_pecas, a.manut_dias, a.ultima_manut,a.om,  a.qtde_produzida,
case
when a.qtde_produzida>=a.manut_pecas
then current_date
when a.ultima_manut is null
then current_date 
else
cast(a.por_data as date)
end
from manutencao_ferramenta a
;



/* View: PROXIMA_PREVENTIVA_RECURSO */
CREATE VIEW PROXIMA_PREVENTIVA_RECURSO(
    PROXIMA_DATA,
    OM,
    RECURSO,
    TIPO_MANUT,
    STATUS)
AS
select max(a.data_programada), max(a.n_cont),a.recurso, a.tipo_manut, a.status
from tb_om a
where tipo_manut = 2 and a.data_programada is not null and a.recurso is not null and status = 2
group by a.recurso, a.tipo_manut, a.status
;



/* View: ULTIMA_PREVENTIVA_RECURSO */
CREATE VIEW ULTIMA_PREVENTIVA_RECURSO(
    RECURSO,
    NOME_RECURSO,
    SETOR,
    NOME_SETOR,
    ULTIMA_DATA,
    OM,
    TIPO_MANUT,
    STATUS,
    ENCERRADA,
    PERIODICIDADE,
    PROXIMA)
AS
select b.idrec, b.nomerec, b.idsetor, c.nomesetor,
case
when a.tipo_manut = 2 then
max(a.data_programada)
else null
end
,
case when a.tipo_manut = 2 then
max(a.n_cont)
else null
end
, a.tipo_manut, a.status,
case when a.tipo_manut =2
then max(a.data_encerrada)
else
null
end
,
b.periodicidade_manutencao,

case when a.tipo_manut =2
then
addday(max(a.data_programada),b.periodicidade_manutencao)
else
addday(current_date,0)
end

from tbrecurso b left join tb_om a on (b.idrec = a.recurso)
left join tbsetor c on (b.idsetor = c.idsetor)
where tipo_manut =2 and b.periodicidade_manutencao > 0 and status =4
group by b.idrec, b.nomerec, b.idsetor, c.nomesetor, a.tipo_manut, a.status, b.periodicidade_manutencao
;



/* View: CRONOGRAMA_PREVENTIVAS_RECURSO */
CREATE VIEW CRONOGRAMA_PREVENTIVAS_RECURSO(
    ULTIMA_DATA,
    OM_ENCERRADA,
    RECURSO,
    NOME_RECURSO,
    SETOR,
    NOME_SETOR,
    TIPO_MANUT,
    STATUS_ENCERRADA,
    ENCERRADA,
    PERIODICIDADE,
    DATA_PREVISTA,
    OM_PROGRAMADA,
    STATUS_PROGRAMADA)
AS
select a.ultima_data, a.om, a.recurso, a.nome_recurso, a.setor, a.nome_setor, a.tipo_manut, a.status, a.encerrada, a.periodicidade,
CASE WHEN b.proxima_data is null
then cast(a.proxima as date)
else
b.proxima_data
end,
b.om, b.status
from ultima_preventiva_recurso a left join proxima_preventiva_recurso b on (a.recurso = b.recurso)
order by a.setor, a.recurso
;



/* View: RECURSOS_NAO_PROGRAMADOS */
CREATE VIEW RECURSOS_NAO_PROGRAMADOS(
    RECURSO,
    NOME_RECURSO,
    SETOR,
    NOME_SETOR,
    ULTIMA_DATA,
    OM,
    ENCERRADA,
    PERIODICIDADE,
    PROXIMA)
AS
select b.idrec, b.nomerec, b.idsetor, c.nomesetor,

null

,
null
,
null
,
b.periodicidade_manutencao,

f_addday(current_date,0)

from tbrecurso b left join tb_om a on (b.idrec = a.recurso)
left join tbsetor c on (b.idsetor = c.idsetor)
/*where tipo_manut in(2,null) and b.periodicidade_manutencao > 0 and status in (4,null)*/
where b.periodicidade_manutencao > 0 AND a.tipo_manut<>2
group by b.idrec, b.nomerec, b.idsetor, c.nomesetor, b.periodicidade_manutencao
;



/* View: CRONOGRAMA_RECURSO_NAO_PROG */
CREATE VIEW CRONOGRAMA_RECURSO_NAO_PROG(
    RECURSO,
    NOME_RECURSO,
    SETOR,
    NOME_SETOR,
    ULTIMA_DATA,
    OM,
    ENCERRADA,
    PERIODICIDADE,
    PROXIMA)
AS
select a.recurso, a.nome_recurso, a.setor, a.nome_setor, a.ultima_data, a.om, a.encerrada, a.periodicidade, a.proxima
from cronograma_preventivas_recurso B RIGHT JOIN  recursos_nao_programados a
ON (B.recurso = A.recurso) WHERE B.recurso IS NULL
;



/* View: NF_FAT_PROD */
CREATE VIEW NF_FAT_PROD(
    NUMNF,
    SISTEMA,
    EMISSAO,
    MESNUM,
    ANO,
    MES,
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    CFOP,
    NFCFOPI,
    DESCCFOP,
    VALORICMS,
    VALORIPI,
    VALORITENS,
    VALORTOTALNF,
    UNIDADE)
AS
select
numnf, sistema, emissao, f_month(EMISSAO),  f_year(emissao), f_cmonthshortlang(EMISSAO,'PT'),  f_dayofmonth(emissao), f_cdowSHORTlang(emissao,'PT') , f_padleft(f_month(emissao),'0',2) || '/' || f_year(EMISSAO) , codcli, tbfor.tbforraz, tbfor.tbforfan  , tipo, canc, vend, nomevend, stacom, tbnf.status,
cfop,nfcfopi, desccfop, cast(valoricms as numeric(14,2)), cast(valoripi as numeric(14,2)), cast(valoritens as numeric(14,2)), cast(valortotalnf as numeric(14,2)), tbnf.unidade
from tbnf left join tbfor on (tbnf.codcli = tbfor.tbforcod)  WHERE (STACOM in(0,4)) and (canc = 'N') and (tipo = 'S')
;



/* View: FAT_MES_ANO */
CREATE VIEW FAT_MES_ANO(
    ANO,
    MES,
    MESNUM,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF)
AS
select ANO, MES, MESNUM, cast(SUM(valoricms) as numeric(14,2)), cast(SUM(valoripi) as numeric(14,2)), cast(SUM(valoritens) as numeric(14,2)), cast(SUM(valortotalnf) as numeric(14,2)) from nf_fat_prod
GROUP BY ANO, MES, MESNUM order by ANO, MESNUM
;



/* View: FAT_BRUTO_MES_ANO */
CREATE VIEW FAT_BRUTO_MES_ANO(
    MES,
    MESNUM,
    ANO,
    TOTAL)
AS
select a.mes, A.mesnum, a.ano,

 (a.vr_nf + coalesce(b.valor, 0)) from fat_mes_ano a left join tb_2014_metal b
on (a.ano = b.ano and a.mes = b.mes) order by a.ano, a.mesnum
;



/* View: CROSS_FAT_ANO */
CREATE VIEW CROSS_FAT_ANO(
    NOME,
    ANO,
    JANEIRO,
    FEVEREIRO,
    MARCO,
    ABRIL,
    MAIO,
    JUNHO,
    JULHO,
    AGOSTO,
    SETEMBRO,
    OUTUBRO,
    NOVEMBRO,
    DEZEMBRO)
AS
select 'FATURAMENTO', a.ano,
max(case when a.mes = 'Jan' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Fev' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Mar' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Abr' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Mai' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Jun' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Jul' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Ago' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Set' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Out' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Nov' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Dez' then coalesce(a.total,0) else 0 end)
from fat_bruto_mes_ano a group by a.ano
;



/* View: NFC */
CREATE VIEW NFC(
    CFOP,
    CFOPI,
    STATUS,
    NUMNF,
    NOTA_FISCAL,
    EMISSAO,
    ANO,
    MES,
    MESNUM,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STAEST,
    STAPED,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    PEDIDOCLI,
    QTDEITEM,
    VLUNIT,
    VLITEM,
    DESENHO,
    NUMPED,
    UND,
    NR,
    TIPOITEM)
AS
select
a.cfop, a.nfcfopi, d.tipo, a.numnf, a.pedidocli, a.emissao,f_year(a.emissao), f_cmonthshortlang(a.emissao,'PT'), f_month(a.emissao),  a.codcli, a.razao, a.fantasia, a.tipo, a.canc, a.vend, a.nomevend, a.staest, a.staped,
b.iditemnf, b.iditemped, b.codigoitem, b.pedidocli, b.qtdeitem, b.vlunit, b.vlitem, b.desenho, b.numped,b.und,b.nr,
c.tipoitem
from tbnfc a join (tbitensnfc b left join tbitens c on (b.codigoitem = c.codigoitem)) on (a.numnf = b.idnumnf)
left join tbcfop d on (a.nfcfopi = d.cfopi)
where a.emissao>='01.01.2015' and a.staest = 1  and a.status in (0,1) and a.cfop in ('1.101','2.101','3.101','1.124','2.124','3.124')
and a.vend in ('150.001','150.003') and a.codcli not in (249)
;



/* View: MP_BRUTO_MES_ANO */
CREATE VIEW MP_BRUTO_MES_ANO(
    NOME,
    MES,
    MESNUM,
    ANO,
    TOTAL)
AS
select A.nomevend, a.mes, A.mesnum, a.ano,
sum(a.vlitem) from nfc a
group by A.nomevend, mes, mesnum, ano order by a.ano, a.mesnum
;



/* View: CROSS_MP_ANO */
CREATE VIEW CROSS_MP_ANO(
    NOME,
    ANO,
    JANEIRO,
    FEVEREIRO,
    MARCO,
    ABRIL,
    MAIO,
    JUNHO,
    JULHO,
    AGOSTO,
    SETEMBRO,
    OUTUBRO,
    NOVEMBRO,
    DEZEMBRO)
AS
select a.nome, a.ano,
max(case when a.mes = 'Jan' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Fev' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Mar' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Abr' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Mai' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Jun' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Jul' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Ago' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Set' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Out' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Nov' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Dez' then coalesce(a.total,0) else 0 end)
from MP_bruto_mes_ano a group by a.nome, a.ano
;



/* View: NFC_OUTROS */
CREATE VIEW NFC_OUTROS(
    CFOP,
    CFOPI,
    STATUS,
    NUMNF,
    NOTA_FISCAL,
    EMISSAO,
    ANO,
    MES,
    MESNUM,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STAEST,
    STAPED,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    PEDIDOCLI,
    QTDEITEM,
    VLUNIT,
    VLITEM,
    DESENHO,
    NUMPED,
    UND,
    NR,
    TIPOITEM)
AS
select
a.cfop, a.nfcfopi, d.tipo, a.numnf, a.pedidocli, a.emissao,f_year(a.emissao), f_cmonthshortlang(a.emissao,'PT'), f_month(a.emissao),  a.codcli, a.razao, a.fantasia, a.tipo, a.canc, a.vend, a.nomevend, a.staest, a.staped,
b.iditemnf, b.iditemped, b.codigoitem, b.pedidocli, b.qtdeitem, b.vlunit, b.vlitem, b.desenho, b.numped,b.und,b.nr,
c.tipoitem
from tbnfc a join (tbitensnfc b left join tbitens c on (b.codigoitem = c.codigoitem)) on (a.numnf = b.idnumnf)
left join tbcfop d on (a.nfcfopi = d.cfopi)
where a.emissao>='01.01.2015' and a.staest = 1
and a.vend not in ('150.001','150.003') and a.codcli not in (249)
;



/* View: OUTROS_BRUTO_MES_ANO */
CREATE VIEW OUTROS_BRUTO_MES_ANO(
    NOME,
    MES,
    MESNUM,
    ANO,
    TOTAL)
AS
select A.nomevend, a.mes, A.mesnum, a.ano,
sum(a.vlitem) from nfc_outros a
group by A.nomevend, mes, mesnum, ano order by a.ano, a.mesnum
;



/* View: CROSS_OUTROS_ANO */
CREATE VIEW CROSS_OUTROS_ANO(
    NOME,
    ANO,
    JANEIRO,
    FEVEREIRO,
    MARCO,
    ABRIL,
    MAIO,
    JUNHO,
    JULHO,
    AGOSTO,
    SETEMBRO,
    OUTUBRO,
    NOVEMBRO,
    DEZEMBRO)
AS
select a.nome, a.ano,
max(case when a.mes = 'Jan' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Fev' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Mar' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Abr' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Mai' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Jun' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Jul' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Ago' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Set' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Out' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Nov' then coalesce(a.total,0) else 0 end),
max(case when a.mes = 'Dez' then coalesce(a.total,0) else 0 end)
from outros_bruto_mes_ano a group by a.nome, a.ano
;



/* View: CROSSTAB_FAT_ANO */
CREATE VIEW CROSSTAB_FAT_ANO(
    ANO,
    JANEIRO,
    FEVEREIRO,
    MARCO,
    ABRIL,
    MAIO,
    JUNHO,
    JULHO,
    AGOSTO,
    SETEMBRO,
    OUTUBRO,
    NOVEMBRO,
    DEZEMBRO)
AS
select a.ano,
max(case when a.mes = 'Jan' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Fev' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Mar' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Abr' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Mai' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Jun' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Jul' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Ago' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Set' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Out' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Nov' then coalesce(a.total/1000,0) else 0 end),
max(case when a.mes = 'Dez' then coalesce(a.total/1000,0) else 0 end)
from fat_bruto_mes_ano a group by a.ano
;



/* View: NF_ENT */
CREATE VIEW NF_ENT(
    NUMNF,
    EMISSAO,
    CODCLI,
    RAZAO,
    TIPO,
    CANC,
    STACOM,
    STATUS,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    PEDIDOCLI,
    NR,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    NUMPED,
    SUBCFOP,
    COD_MOV,
    DESC_PARAMETRO,
    MOV_ESTOQUE,
    FISICO)
AS
select
numnf, tbnfc.sistema, codcli, razao, tipo, canc, stacom, tbnfc.status,
iditemnf, iditemped, tbitens.codigoitem, tbnfc.pedidocli, tbitensnfc.nr,  qtdeitem * tbitens.fatorconvitem ,und, vlunit, vlitem,
numped, TBNFc.nfcfopi, cfop_estoque.cod_parametro, cfop_estoque.desc_paramentro,    cfop_estoque.mov_estoque, cfop_estoque.fisico
from tbnfc join tbitensnfc on (idnumnf = numnf) LEFT join cfop_estoque ON (TBNFc.nfcfopi  = cfop_estoque.cfopi)
left join tbitens on (tbitensnfc.codigoitem = tbitens.codigoitem)
WHERE cfop_estoque.fisico = 1
;



/* View: CS_ENT */
CREATE VIEW CS_ENT(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    LOTE,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select 'ENT', nf_ent.emissao , nf_ent.pedidocli, nf_ent.razao, nf_ent.nr , nf_ent.qtdeitem , nf_ent.codigoitem, nf_ent.canc,
NF_ent.subcfop, NF_ent.mov_estoque, NF_ent.cod_mov,nf_ent.desc_parametro,   NF_ent.fisico
from nf_ent order by nf_ent.pedidocli, codigoitem
;



/* View: CS_ESTOQUES_FISICO */
CREATE VIEW CS_ESTOQUES_FISICO(
    ORIGEM,
    CODIGOITEM,
    NOMEITEM,
    REFITEM,
    UNDUSOITEM,
    TIPOITEM,
    CODFOR,
    NOME,
    ENTRADA,
    LOTE,
    NOTA_FISCAL,
    OS,
    POSICAO,
    ESTOQUE_TERC,
    ESTOQUE_PROC,
    ESTOQUE_DISP,
    ESTOQUE_RESERVADO,
    ESTOQUE_FISICO,
    TIPO,
    ESP,
    LARG,
    DESENHOITEM,
    LOCAL)
AS
select 'FISICO', tbitens.codigoitem, tbitens.nomeitem, tbitens.refitem, tbitens.undusoitem, tbitens.tipoitem,
tblote.codfor, TBFOR.tbforfan ,  tblote.entrada, tblote.lote, tblote.nota_fiscal, tblote.os, tblote.posicao,0, 0, tblote.saldolote, TBLOTE.qtde_reserv, TBLOTE.saldolote + TBLOTE.qtde_reserv,   tblote.tipo
, TBITENS.espessuraitem , TBITENS.larguraitem , tbitens.desenhoitem , tblote.local
from tbitens left join tblote on (tbitens.codigoitem = tblote.codigoitem) LEFT JOIN tbfor ON (TBLOTE.codfor = tbfor.tbforcod) where tblote.tipo = 0
;



/* View: CS_ESTOQUES_PROCESSO */
CREATE VIEW CS_ESTOQUES_PROCESSO(
    ORIGEM,
    CODIGOITEM,
    NOMEITEM,
    REFITEM,
    UNDUSOITEM,
    TIPOITEM,
    CODFOR,
    NOME,
    ENTRADA,
    LOTE,
    NOTA_FISCAL,
    OS,
    POSICAO,
    ESTOQUE_TERC,
    ESTOQUE_PROC,
    ESTOQUE_DISP,
    ESTOQUE_RESERVADO,
    ESTOQUE_FISICO,
    TIPO,
    ESP,
    LARG,
    DESENHOITEM,
    LOCAL)
AS
select 'PROCESSO', tbitens.codigoitem, tbitens.nomeitem, tbitens.refitem, tbitens.undusoitem, tbitens.tipoitem,
tb_os.codigo_cliente , tb_os.nome_cliente, tb_os.data , '', '', tb_os.numero_os , tb_os.status , TB_OS.total_terceiro,  tb_os.saldo ,0, 0, 0, 0,
 TBITENS.espessuraitem , TBITENS.larguraitem, tbitens.desenhoitem , ''
from tbitens left join tb_os on (tbitens.codigoitem = tb_os.produto)
;



/* View: CS_ESTOQUES */
CREATE VIEW CS_ESTOQUES(
    CODFOR,
    CODIGOITEM,
    ENTRADA,
    ESTOQUE_DISP,
    ESTOQUE_RESERVADO,
    ESTOQUE_FISICO,
    ESTOQUE_PROC,
    ESTOQUE_TERC,
    LOTE,
    NOME,
    NOMEITEM,
    NOTA_FISCAL,
    ORIGEM,
    OS,
    POSICAO,
    REFITEM,
    TIPO,
    TIPOITEM,
    UNDUSOITEM,
    ESP,
    LARG,
    DESENHOITEM,
    LOCAL)
AS
select codfor, codigoitem, entrada, estoque_DISP, ESTOQUE_RESERVADO, ESTOQUE_FISICO, estoque_proc, estoque_terc, lote, nome, nomeitem, nota_fiscal, origem, os, posicao, refitem, tipo, tipoitem, undusoitem,
cs_estoques_fisico.esp, cs_estoques_fisico.larg, cs_estoques_fisico.desenhoitem, cs_estoques_fisico.local  from cs_estoques_fisico union all

select codfor, codigoitem, entrada, estoque_DISP, ESTOQUE_RESERVADO, ESTOQUE_FISICO, estoque_proc, estoque_terc, lote, nome, nomeitem, nota_fiscal, origem, os, posicao, refitem, tipo, tipoitem, undusoitem
, esp, larg, cs_estoques_processo.desenhoitem, cs_estoques_processo.local from cs_estoques_processo
;



/* View: CS_EVENTOS */
CREATE VIEW CS_EVENTOS(
    ORDEM,
    IDMOV,
    LOTE_BANCO,
    IDFATURA,
    DATAMOV,
    DESCMOV,
    IDBANCO,
    VALOR,
    DOCTO,
    TIPO,
    MEIOPGTO,
    CHEQUE,
    NOMEBANCO,
    CODIGOBANCO,
    AGENCIA,
    NUMCONTA,
    CODCLI,
    NOME,
    COD_FINANCEIRO,
    NOME_FINANCEIRO)
AS
select
1,
verfatura.idmov, 0,
verfatura.idpagrec,
VERFATURA.datapgto,
nome_evento,
banco,
case when eventos.tipo_ev = 0 then
valor_informado * - 1
else
valor_informado
end
, verfatura.docto,
EVENTOS.tipo,
VERFATURA.formpag,
'',
verfatura.nomebanco,
'',
'',
'', verfatura.codforcli, verfatura.descr, verfatura.coddesp, VERFATURA.nomeconta 
from verfatura left join EVENTOS ON (VERFATURA.idpagrec = EVENTOS.id_fatura)
where verfatura.datapgto is not null
order by VERFATURA.coddesp
;



/* View: NF_OS */
CREATE VIEW NF_OS(
    NUMNF,
    EMISSAO,
    CODCLI,
    RAZAO,
    TIPO,
    CANC,
    STACOM,
    STATUS,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    DESENHO,
    N_OS,
    QT_OS,
    N_OS2,
    QT_OS2,
    N_OS3,
    QT_OS3,
    N_OS4,
    QT_OS4,
    NUMPED,
    NF_NUMERO,
    SUBCFOP,
    COD_MOV,
    DESC_PARAMETRO,
    MOV_ESTOQUE,
    FISICO)
AS
select
numnf, emissao, codcli, razao, tipo, canc, stacom, tbnf.status,
iditemnf, iditemped, codigoitem, tbitensnf.pedidocli, qtdeitem,und, vlunit, vlitem, desenho,
n_os, qt_os, n_os2, qt_os2, n_os3, qt_os3, n_os4, qt_os4,
numped, nf_numero, TBNF.nfcfopi, cfop_estoque.cod_parametro, cfop_estoque.desc_paramentro,    cfop_estoque.mov_estoque, cfop_estoque.fisico
from tbnf join tbitensnf on (idnumnf = numnf) LEFT join cfop_estoque ON (TBNF.nfcfopi = cfop_estoque.cfopi) WHERE stacom = 0
;



/* View: CS_OS */
CREATE VIEW CS_OS(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    OS,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select 'FAT', nf_os.emissao, nf_os.nf_numero, nf_os.razao, 0, nf_os.qtdeitem , nf_os.codigoitem, nf_os.canc,
NF_OS.subcfop, NF_OS.mov_estoque, NF_OS.cod_mov,nf_os.desc_parametro,   NF_OS.fisico
from nf_os order by nf_os.nf_numero, codigoitem
;



/* View: NF_ENTRADA_ESTOQUE */
CREATE VIEW NF_ENTRADA_ESTOQUE(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    LOTE,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select 'EST', MOVIMENTO.datalanc, MOVIMENTO.nota_fiscal, MOVIMENTO.historico, MOVIMENTO.lote ,
MOVIMENTO.qtd_mov * -1, MOVIMENTO.codigomat, '', MOVIMENTO.cfop, 'SIM', MOVIMENTO.cod_parametro, movimento.nome_parametro,  tb_parametro_movimentacao.estoque_fisico
FROM movimento  left join tb_parametro_movimentacao on (movimento.cod_parametro = tb_parametro_movimentacao.cod_parametro) where MOVIMENTO.cod_parametro IN ('01.05', '01.06', '01.07') and movimento.tipo_item IN ('PRODUTO ACABADO', 'COMPONENTE COMPRADO', 'MATERIA-PRIMA')
;



/* View: CS_OS_ENT */
CREATE VIEW CS_OS_ENT(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    LOTE,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select origem, emissao, nota, razao, lote, qtd_os, codigo, canc, subcfop, mov_estoque, cod_mov, desc_parametro, fisico
from cs_ent union all
select origem, emissao, nota, razao, lote, qtd_os, codigo, canc, subcfop, mov_estoque, cod_mov, desc_parametro, fisico
from nf_entrada_estoque
;



/* View: NF_SAIDA_ESTOQUE */
CREATE VIEW NF_SAIDA_ESTOQUE(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    OS,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select 'EST', MOVIMENTO.datalanc, MOVIMENTO.nota_fiscal, MOVIMENTO.historico, MOVIMENTO.os,
MOVIMENTO.qtd_mov, MOVIMENTO.codigomat, '', MOVIMENTO.cfop, 'SIM', MOVIMENTO.cod_parametro, movimento.nome_parametro,  tb_parametro_movimentacao.estoque_fisico 
FROM movimento  left join tb_parametro_movimentacao on (movimento.cod_parametro = tb_parametro_movimentacao.cod_parametro) where movimento.grupo = 2 and movimento.tipo_item = 'PRODUTO ACABADO'
;



/* View: CS_OS_FAT */
CREATE VIEW CS_OS_FAT(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    OS,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select origem, emissao, nota, razao, os, qtd_os, codigo, canc, subcfop, mov_estoque, cod_mov, desc_parametro, fisico
from cs_os UNION all
select origem, emissao, nota, razao, os, qtd_os, codigo, canc, subcfop, mov_estoque, cod_mov, desc_parametro,fisico
from nf_saida_estoque
;



/* View: NF_TERC */
CREATE VIEW NF_TERC(
    NUMNF,
    EMISSAO,
    CODCLI,
    RAZAO,
    TIPO,
    CANC,
    STACOM,
    STATUS,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    PEDIDOCLI,
    NR,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    NUMPED,
    SUBCFOP,
    COD_MOV,
    DESC_PARAMETRO,
    MOV_ESTOQUE,
    FISICO)
AS
select
numnf, tbnfc.sistema, codcli, razao, tipo, canc, stacom, tbnfc.status,
iditemnf, iditemped, tbitens.codigoitem, tbnfc.pedidocli, tbitensnfc.nr,
case when tbitens.pesoliqitem = 0 then 1
when tbitens.pesoliqitem is null then 1
else
cast(qtdeitem / tbitens.pesoliqitem as numeric(15,0))
end
,und, vlunit, vlitem,

numped, TBNFc.nfcfopi, cfop_estoque.cod_parametro, cfop_estoque.desc_paramentro,    cfop_estoque.mov_estoque, cfop_estoque.fisico
from tbnfc join tbitensnfc on (idnumnf = numnf) LEFT join cfop_estoque ON (TBNFc.nfcfopi  = cfop_estoque.cfopi)
left join tbitens on (tbitensnfc.codigoitem = tbitens.codigoitem)
WHERE cfop_estoque.servico = 1
;



/* View: CS_TERC */
CREATE VIEW CS_TERC(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    LOTE,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select 'ENT', nf_terc.emissao , nf_terc.pedidocli, nf_terc.razao, nf_terc.nr , nf_terc.qtdeitem , nf_terc.codigoitem, nf_terc.canc,
nf_terc.subcfop, nf_terc.mov_estoque, nf_terc.cod_mov,nf_terc.desc_parametro,   nf_terc.fisico
from nf_terc where nf_terc.emissao > '01.11.2010' order by nf_terc.pedidocli, codigoitem
;



/* View: NF_ENTRADA_TERCEIRO */
CREATE VIEW NF_ENTRADA_TERCEIRO(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    LOTE,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select 'EST', MOVIMENTO.datalanc, MOVIMENTO.nota_fiscal, MOVIMENTO.historico, MOVIMENTO.lote ,
MOVIMENTO.qtdeserv * -1, MOVIMENTO.codigomat, '', MOVIMENTO.cfop, 'SIM', MOVIMENTO.cod_parametro, movimento.nome_parametro,  tb_parametro_movimentacao.estoque_fisico
FROM movimento  left join tb_parametro_movimentacao on (movimento.cod_parametro = tb_parametro_movimentacao.cod_parametro) where MOVIMENTO.cod_parametro IN ('01.10') and movimento.tipo_item IN ('PRODUTO ACABADO', 'COMPONENTE COMPRADO', 'MATERIA-PRIMA')
and movimento.datalanc >='01.11.2010'
;



/* View: CS_OS_TERC */
CREATE VIEW CS_OS_TERC(
    ORIGEM,
    EMISSAO,
    NOTA,
    RAZAO,
    LOTE,
    QTD_OS,
    CODIGO,
    CANC,
    SUBCFOP,
    MOV_ESTOQUE,
    COD_MOV,
    DESC_PARAMETRO,
    FISICO)
AS
select origem, emissao, nota, razao, lote, qtd_os, codigo, canc, subcfop, mov_estoque, cod_mov, desc_parametro, fisico
from cs_terc union all
select origem, emissao, nota, razao, lote, qtd_os, codigo, canc, subcfop, mov_estoque, cod_mov, desc_parametro, fisico
from nf_entrada_terceiro
;



/* View: CUSTO_ESTRUTURA */
CREATE VIEW CUSTO_ESTRUTURA(
    CODIGOITEM,
    VALORCUSTOITEM,
    TIPOITEM)
AS
select
f_left( f_replace(codigoitem,'.',''),10)||f_right(codigoitem,1),

valorcustoitem, tipoitem
from tbitens where tipoitem in('COMPONENTE FABRICADO', 'PRODUTO ACABADO')
ORDER BY CODIGOITEM
;



/* View: MOVIMENTO_RECEBIDO */
CREATE VIEW MOVIMENTO_RECEBIDO(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    QTDCOMPRA,
    QTDENTRADA,
    QTDINSPECAO,
    QTDSAIDA,
    SETOR,
    SALDOCOMPRA,
    SALDOINSPECAO,
    SALDOFISICO,
    VALORMEDIO,
    VALORLANC,
    HISTORICO,
    UND,
    LOTE,
    SALDORESERV,
    SALDOSERV,
    SALDODISP,
    SALDOPROC,
    QTDERESERV,
    QTDESERV,
    QTDEPROC,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    REQUISICAO,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    VALOR_TOTAL,
    QTD_MOV,
    VALOR_MOV,
    VALOR_MEDIO,
    TIPO_ITEM,
    INVENTARIO,
    LOTE_OS,
    VALOR_INFORMADO)
AS
select idlanc, datasis, datalanc, codigomat, idpedido, iditemped, docto, os, qtdcompra, qtdentrada, qtdinspecao, qtdsaida, setor, saldocompra, saldoinspecao, saldofisico, valormedio,
case when
tbitens.custoacabitem > 0 then tbitens.custoacabitem 
else valorlanc
end,
historico, und, lote, saldoreserv, saldoserv, saldodisp, saldoproc, qtdereserv, qtdeserv, qtdeproc,
tblanc.cod_parametro, tblanc.cfop, tblanc.codfor, tblanc.requisicao, tblanc.nota_fiscal, 
nome_parametro, nomeitem, tb_parametro_movimentacao.grupo, TBLANC.mes_lanc, TBLANC.status, TBLANC.usuario,
TBLANC.hora_lanc,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then cast(TBITENS.custoacabitem as digito16)
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then cast(TBITENS.custoacabitem * tblanc.qtdsaida as digito16)
else cast(TBITENS.custoacabitem * tblanc.qtdentrada as numeric_12_6)
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then cast(tblanc.valorlanc as digito16)
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then cast(tblanc.valorlanc * tblanc.qtdsaida as digito16)
else cast(tblanc.valorlanc * tblanc.qtdentrada as digito16)
end
end,
case
when tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then 0
when tblanc.qtdentrada <> 0 then tblanc.qtdentrada
when tblanc.qtdsaida <> 0 then (tblanc.qtdsaida * -1)
else 0
end,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then cast(TBITENS.custoacabitem as digito16)
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then cast(((TBITENS.custoacabitem * tblanc.qtdsaida) * -1) as digito16)
when tbitens.custoacabitem > 0 and tblanc.qtdentrada <> 0 then cast(tbitens.custoacabitem * tblanc.qtdentrada as digito16)
else 0
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then cast(tblanc.valorlanc as digito16)
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then cast(((tblanc.valorlanc * tblanc.qtdsaida)* -1) as digito16)
when tblanc.valorlanc > 0 and tblanc.qtdentrada <> 0 then cast(tblanc.valorlanc * tblanc.qtdentrada as digito16)
else 0
end
end,
case
when tblanc.valorMEDIO > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then cast(tblanc.valormedio as digito16)
when tblanc.valormedio > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then cast((tblanc.valormedio * tblanc.qtdsaida)as digito16)
when tblanc.valormedio > 0 and tblanc.qtdentrada <> 0 then cast((tblanc.valormedio * tblanc.qtdentrada) as digito16)
else 0
end,
tbitens.tipoitem, tbtipoitem.inventario,
case
when tbitens.tipoitem = 'PRODUTO ACABADO' THEN TBLANC.os
when tbitens.tipoitem = 'COMPONENTE FABRICADO' THEN TBLANC.OS
when tbitens.tipoitem = 'COMPONENTE COMPRADO' THEN TBLANC.lote 
when tbitens.tipoitem = 'MAT�RIA-PRIMA' THEN TBLANC.LOTE
END,
tbitens.custoacabitem 
from tblanc left join tbitens on (codigomat = codigoitem)
left join tb_parametro_movimentacao on (tblanc.cod_parametro = tb_parametro_movimentacao.cod_parametro)
left join tbtipoitem on (tbitens.tipoitem = tbtipoitem.tipoitem)
where tblanc.datalanc >='01.01.2011' and tblanc.grupo in (0,1) and tbitens.tipoitem in ('PRODUTO ACABADO', 'COMPONENTE COMPRADO', 'COMPONENTE FABRICADO', 'MAT�RIA-PRIMA')
order by tblanc.idlanc
;



/* View: ENTRADAS_RECEBIDAS */
CREATE VIEW ENTRADAS_RECEBIDAS(
    CODIGOMAT,
    QTDENTRADA,
    VALOR_TOTAL,
    VALOR_UNIT,
    TIPO_ITEM,
    UND,
    LOTE)
AS
select codigomat, sum(qtd_mov), cast(sum(valor_mov) as digito16), avg(movimento_recebido.valorlanc),
movimento_recebido.tipo_item, movimento_recebido.und, LOTE
from movimento_recebido  where
MOVIMENTO_RECEBIDO.cod_parametro in ('01.05','01.07') AND TIPO_ITEM IN ('MAT�RIA-PRIMA','COMPONENTE COMPRADO')
group by codigomat, tipo_item, movimento_recebido.und, LOTE
having (f_stringlength(codigomat) > 1
and sum(movimento_recebido.valor_mov) <> 0 and sum(qtd_mov)<>0) /* and sum(valor_total) > 0 */
order by LOTE
;



/* View: MOVIMENTO_SAIDA_OS */
CREATE VIEW MOVIMENTO_SAIDA_OS(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    QTDCOMPRA,
    QTDENTRADA,
    QTDINSPECAO,
    QTDSAIDA,
    SETOR,
    SALDOCOMPRA,
    SALDOINSPECAO,
    SALDOFISICO,
    VALORMEDIO,
    VALORLANC,
    HISTORICO,
    UND,
    LOTE,
    SALDORESERV,
    SALDOSERV,
    SALDODISP,
    SALDOPROC,
    QTDERESERV,
    QTDESERV,
    QTDEPROC,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    REQUISICAO,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    VALOR_TOTAL,
    QTD_MOV,
    VALOR_MOV,
    VALOR_MEDIO,
    TIPO_ITEM,
    INVENTARIO,
    LOTE_OS,
    VALOR_INFORMADO,
    OS__ORIGEM)
AS
select idlanc, datasis, datalanc, tblanc.codigomat, idpedido, iditemped, docto, tblanc.os, qtdcompra, qtdentrada, qtdinspecao, qtdsaida, setor, saldocompra, saldoinspecao, saldofisico, valormedio,
case when
tbitens.custoacabitem > 0 then tbitens.custoacabitem 
else valorlanc
end,
historico, und, tblanc.lote, saldoreserv, saldoserv, saldodisp, saldoproc, qtdereserv, qtdeserv, qtdeproc,
tblanc.cod_parametro, tblanc.cfop, tblanc.codfor, tblanc.requisicao, tblanc.nota_fiscal, 
nome_parametro, nomeitem, tb_parametro_movimentacao.grupo, TBLANC.mes_lanc, TBLANC.status, TBLANC.usuario,
TBLANC.hora_lanc,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then TBITENS.custoacabitem * tblanc.qtdsaida
else TBITENS.custoacabitem * tblanc.qtdentrada
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then tblanc.valorlanc * tblanc.qtdsaida
else tblanc.valorlanc * tblanc.qtdentrada
end
end,
case
when tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then 0
when tblanc.qtdentrada <> 0 then tblanc.qtdentrada
when tblanc.qtdsaida <> 0 then (tblanc.qtdsaida * -1)
else 0
end,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (TBITENS.custoacabitem * tblanc.qtdsaida) * -1
when tbitens.custoacabitem > 0 and tblanc.qtdentrada <> 0 then (tbitens.custoacabitem * tblanc.qtdentrada)
else 0
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valorlanc * tblanc.qtdsaida)* -1
when tblanc.valorlanc > 0 and tblanc.qtdentrada <> 0 then (tblanc.valorlanc * tblanc.qtdentrada)
else 0
end
end,
case
when tblanc.valorMEDIO > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valormedio
when tblanc.valormedio > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valormedio * tblanc.qtdsaida)
when tblanc.valormedio > 0 and tblanc.qtdentrada <> 0 then (tblanc.valormedio * tblanc.qtdentrada)
else 0
end,
tbitens.tipoitem, tbtipoitem.inventario,
case
when tbitens.tipoitem = 'PRODUTO ACABADO' THEN TBLANC.os
when tbitens.tipoitem = 'COMPONENTE FABRICADO' THEN TBLANC.OS
when tbitens.tipoitem = 'COMPONENTE COMPRADO' THEN TBLANC.lote 
when tbitens.tipoitem = 'MAT�RIA-PRIMA' THEN TBLANC.LOTE
END,
tbitens.custoacabitem, tblote.os
from tblanc left join tbitens on (codigomat = codigoitem)
left join tb_parametro_movimentacao on (tblanc.cod_parametro = tb_parametro_movimentacao.cod_parametro)
left join tbtipoitem on (tbitens.tipoitem = tbtipoitem.tipoitem)
left join tblote on (tblanc.lote = tblote.lote)
where tbitens.tipoitem IN ('MAT�RIA-PRIMA','COMPONENTE COMPRADO','COMPONENTE FABRICADO') AND TBLANC.cod_parametro in ('03.05','03.06','03.09')
and tblanc.datalanc >= '01.10.2012'
;



/* View: LOTES_SAIDAS_OS */
CREATE VIEW LOTES_SAIDAS_OS(
    OS,
    LOTE,
    CODIGO,
    OS_ORIGEM)
AS
select a.os, a.lote, a.codigomat, a.os__origem from movimento_saida_os a
group by a.os, a.lote, a.codigomat , a.os__origem
;



/* View: CUSTO_POR_OS */
CREATE VIEW CUSTO_POR_OS(
    ESTRUTURA,
    OS,
    PRODUTO,
    TIPO_PRODUTO,
    CODIGOITEM,
    OS_ORIGEM,
    QTD_POR,
    UNITARIO,
    UND,
    CUSTO_ITEM,
    TIPO_ITEM)
AS
select b.arvore, a.os, b.produto, d.tipoitem, a.codigo,a.os_origem, b.consumo_unit, avg(c.valor_unit), c.und, (b.consumo_unit * avg(c.valor_unit)), b.tipomp
from lotes_saidas_os a left join (estrut_os b left join tbitens d on (b.produto = d.codigoitem)) on (a.os = b.n_os and a.codigo = b.codigo)
left join entradas_recebidas c on (a.lote = c.lote)
where b.tipo_est = '0'
group by b.arvore, a.os, b.produto, d.tipoitem, a.codigo, a.os_origem, b.consumo_unit, c.und, b.tipomp
order by a.os
;



/* View: DADOS_NOTA */
CREATE VIEW DADOS_NOTA(
    NUMNF,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    RAZAO,
    FANTASIA,
    CNPJCLI,
    INSCCLI,
    CPAG,
    STATUS,
    TIPO,
    CANC,
    CFOP,
    DESCCFOP,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    TBFORENDERTRANSP,
    TBFORBAIRROTRANSP,
    TBFORCEPTRANSP,
    TBFORCIDTRANSP,
    TBFORESTTRANSP,
    TIPOTRANSP,
    PLACATRANSP,
    UFPLACATRANSP,
    INSCTRANSP,
    CNPJTRANSP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSNF,
    ICMS,
    TF,
    BASEICMS,
    VALORICMS,
    VALORIPI,
    BASEICMSSUBST,
    VALORICMSSUBST,
    VALORITENS,
    VALORISS,
    VALORTOTALNF,
    VALORSERVICO,
    VALORFRETE,
    VALORSEGURO,
    OUTRASDEPESAS,
    QTDEVOL,
    VOLUME,
    ESPECIE,
    MARCA,
    PESOBRUTO,
    PESOLIQ,
    NOSSOPED,
    PEDIDOCLI,
    NFRECUSA,
    VEND,
    NOMEVEND,
    STAICMS,
    STAIPI,
    STASUFRAMA,
    STAIMP,
    STAEST,
    STAPED,
    STACOM,
    NFCFOPI,
    DADOS_ADICIONAIS,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    CHAVE_ACESSO,
    UNIDADE,
    DESCSERV,
    NF_NUMERO)
AS
select
tbnf.numnf, tbnf.emissao, tbnf.sistema, tbnf.saida, tbnf.codcli,
tbfor.tbforraz , tbfor.tbforfan  , tbfor.tbforcnpj , tbfor.tbforinscest , tbnf.cpag, tbnf.status, tbnf.tipo, tbnf.canc, tbnf.cfop, tbnf.desccfop,
      tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest, tbfor.tbforendercob, tbfor.tbforbairrocob,
      tbfor.tbforcepcob, tbfor.tbforcidcob, tbfor.tbforestcob, tbfor.tbforenderent, tbfor.tbforbairroent, tbfor.tbforcepent,
      tbfor.tbforcident, tbfor.tbforestent, tbnf.tbforcodtransp, tbnf.tbfornometransp, tbnf.tbforendertransp, tbnf.tbforbairrotransp, tbnf.tbforceptransp, tbnf.tbforcidtransp,
      tbnf.tbforesttransp, tbnf.tipotransp, tbnf.placatransp, tbnf.ufplacatransp, tbnf.insctransp, tbnf.cnpjtransp, tbnf.comissaoven, tbnf.comissaorep, tbnf.comissaoint, tbnf.comissaoext,
      tbnf.obsnf, tbnf.icms, tbnf.tf, tbnf.baseicms, tbnf.valoricms, tbnf.valoripi, tbnf.baseicmssubst, tbnf.valoricmssubst, tbnf.valoritens,
      tbnf.valoriss, tbnf.valortotalnf, tbnf.valorservico, tbnf.valorfrete, tbnf.valorseguro, tbnf.outrasdepesas, tbnf.qtdevol,
      tbnf.volume, tbnf.especie, tbnf.marca, tbnf.pesobruto, tbnf.pesoliq, tbnf.nossoped, tbnf.pedidocli, tbnf.nfrecusa,
      tbnf.vend, tbnf.nomevend, tbnf.staicms, tbnf.staipi, tbnf.stasuframa, tbnf.staimp, tbnf.staest, tbnf.staped, tbnf.stacom,
      tbnf.nfcfopi,tbnf.dados_adicionais,  tbfor.codigo_municipio, tbfor.codigo_uf, tbfor.endereco_numero, tbfor.complemento, tbfor.codigo_municipio_ent, tbfor.codigo_uf_ent, tbfor.endereco_numero_ent,
      tbfor.complemento_ent, tbfor.codigo_municipio_cob, tbfor.codigo_uf_cob, tbfor.endereco_numero_cob, tbfor.complemento_cob, tbnf.chave_acesso, tbnf.unidade, tbnf.descserv, tbnf.nf_numero
from tbnf left join tbfor on (tbnf.codcli = tbfor.tbforcod)
;



/* View: NOTASFISCAISC */
CREATE VIEW NOTASFISCAISC(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    DESENHO,
    NUMPED,
    IPI,
    ICMS,
    VLTOT,
    VLIPI,
    NR,
    NFRECUSA,
    NFSAIDA,
    N_OS,
    N_ET,
    QTD_VOL,
    VOLUME,
    ESPECIFICACAO,
    UNIDADE,
    PESO_LIQ,
    CC1,
    CC2,
    CC3,
    CC4,
    CC5,
    CNPJ,
    STAEST,
    TIPO_ITEM,
    CONVERSAO,
    ITEM_NF,
    PLANTA)
AS
select
numnf, emissao,sistema, codcli,NFCFOPI, tbnfc.CFOP,tbnfc.desccfop,  razao, fantasia,cast(VALORTOTALNF as numeric(14,2)), tbnfc.tipo, canc, vend, TBNFC.status, NOMEVEND,
iditemnf, iditemped, tbitensnfc.codigoitem, DESCRICAO, tbNFC.pedidocli, qtdeitem,tbitensnfc.und, tbitensnfc.vlunit, cast(tbitensnfc.vlitem as numeric(14,2)), tbitensnfc.desenho, numped,
tbitensnfc.ipi, tbnfc.icms, cast(vltot as numeric(14,2)), vlipi, nr, nfrecusa, TBITENSNFC.nfsaida , tbpropitemc.opnum ,
case tbpropitemc.et
when '000-' then '0000'
when '-' then '0000'
when '' then '0000'
when null then '0000'
else f_padleft(tbpropitemc.et,'0',4)
end
,tbitensnfc.sittrib,TBITENSNFC.classfiscal,  tbpropitemc.descorcam, tbnfc.unidade,
tbitens.pesoliqitem, tbpropitemc.cc1, tbpropitemc.cc2,  tbpropitemc.cc3, tbpropitemc.cc4,  tbpropitemc.cc5 , tbnfc.cnpjcli,
tbnfc.staest, tbitens.tipoitem, TBITENS.fatorconvitem, tbitensnfc.item_nf, tbsetor.nomesetor
from tbnfc join tbitensnfc left join (tbpropitemc left join tbsetor on (tbpropitemc.posicao = tbsetor.idsetor))  on(tbpropitemc.iditem = tbitensnfc.iditemped)
 on (idnumnf = numnf)
left join tbitens on (tbitensnfc.codigoitem = tbitens.codigoitem)
;



/* View: DBNR */
CREATE VIEW DBNR(
    CODPRO,
    LOTE,
    DATA,
    QTDE,
    OPERACAO,
    C_F,
    CODCF,
    DESCCF,
    T_DOC,
    DOC,
    TPEDIDO,
    VALOR,
    CERTIF,
    TFORN,
    TOTAL,
    ST,
    NNF,
    DTMOV,
    FLAG,
    OS,
    VOLUME,
    ETIQUETA,
    REG,
    UNID)
AS
select f_left(f_replace(codigoitem,'.',''),10)||f_right(codigoitem,1), nr, sistema, qtdeitem,
case
when status = 0 then 'C'
when status = 1 then 'S'
end,
'F', nfrecusa, fantasia, 'N',pedidocli,numped,vlunit,'1','1',vltot,n_et,nfsaida,
sistema, '*', n_os,notasfiscaisc.qtd_vol , 1,'', und
from notasfiscaisc where (nr is not null) and (nr <> 0)
;



/* View: DEMANDA */
CREATE VIEW DEMANDA(
    CODPROD,
    PRAZO)
AS
select codprod, max(prazo)
 from tbpropitem group by codprod order by codprod, max(prazo)
;



/* View: DEMANDA_ITEM */
CREATE VIEW DEMANDA_ITEM(
    CODPROD,
    NOMEITEM,
    TIPO_ITEM,
    QTD_DEMANDA,
    SEMANA)
AS
select pedido.codprod,pedido.nomeprod , pedido.tipo_item ,  sum(saldo), cast(pedido.semana as integer)
from pedido where saldo > 0 and semana <> '-' and pedido.st in (3,4)
group by pedido.codprod, pedido.nomeprod, pedido.tipo_item, cast(pedido.semana as integer)
order by cast(semana as integer)
;



/* View: DEMANDA_ITEM_MENSAL */
CREATE VIEW DEMANDA_ITEM_MENSAL(
    CODPROD,
    NOMEITEM,
    TIPO_ITEM,
    QTD_DEMANDA,
    ANOMES)
AS
select pedido.codprod,pedido.nomeprod , pedido.tipo_item ,  sum(saldo), anomes
from pedido where saldo > 0 and anomes is not null and pedido.st in (3,4) and anomes >='201101'
group by pedido.codprod, pedido.nomeprod, pedido.tipo_item, pedido.mes, anomes
order by anomes
;



/* View: DEMANDA_ITEM_MES */
CREATE VIEW DEMANDA_ITEM_MES(
    CODPROD,
    NOMEITEM,
    TIPO_ITEM,
    DESENHOITEM,
    CLIENTE,
    QTD_DEMANDA,
    MESBASE,
    MES,
    ANO)
AS
select pedido.codprod,tbitens.nomeitem, tbitens.tipoitem,tbitens.desenhoitem,
case f_left(pedido.fantasia,2)
when 'VW' THEN 'VW'
WHEN 'VO' THEN 'VW'
WHEN 'TR' THEN 'TRW'
WHEN 'JO' THEN 'JONHSON CONTROLS'
else PEDIDO.fantasia 
END, sum(saldo),mesbase, f_left(pedido.mesbase,2),
f_right(pedido.mesbase,4)
from pedido join tbitens on (pedido.codprod = tbitens.codigoitem)
group by pedido.codprod, tbitens.nomeitem, tbitens.tipoitem,desenhoitem,
case f_left(pedido.fantasia,2)
when 'VW' THEN 'VW'
WHEN 'VO' THEN 'VW'
WHEN 'TR' THEN 'TRW'
WHEN 'JO' THEN 'JONHSON CONTROLS'
else PEDIDO.fantasia 
END,
  mesbase ,
f_left(pedido.mesbase,2),
f_right(pedido.mesbase,4)
having (sum(saldo) > 0 and mesbase in ('12/2009','01/2010','02/2010'))
order by codprod,
f_right(pedido.mesbase,4), f_left(pedido.mesbase,2)
;



/* View: NF_DEV_PROD */
CREATE VIEW NF_DEV_PROD(
    NUMNF,
    SISTEMA,
    EMISSAO,
    ANO,
    MES,
    MESNUM,
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    CFOP,
    NFCFOPI,
    DESCCFOP,
    VALORICMS,
    VALORIPI,
    VALORITENS,
    VALORTOTALNF,
    UNIDADE,
    PEDIDOCLI)
AS
select
numnf, sistema, emissao,f_year(sistema), f_cmonthshortlang(sistema,'PT'), f_month(sistema),  f_dayofmonth(sistema), f_cdowSHORTlang(sistema,'PT') , f_padleft(f_month(sistema),'0',2) || '/' || f_year(sistema) , codcli, razao, fantasia, tipo, canc, vend, nomevend, stacom, tbnfc.status,
cfop,nfcfopi, desccfop, valoricms, valoripi, valoritens, valortotalnf, tbnfc.unidade, tbnfc.pedidocli
from tbnfc WHERE (staest = 1) and (status =7)
;



/* View: DEVOLUCAO_MES */
CREATE VIEW DEVOLUCAO_MES(
    MES_ANO,
    TOTAL,
    MES,
    ANO,
    MESNUM)
AS
select mes_ano, SUM(valortotalnf), mes, ano, mesnum from nf_dev_prod
GROUP BY mes_ano, mes, ano ,mesnum order by ANO, MESNUM
;



/* View: FAT_CLIENTES_MES_ANO */
CREATE VIEW FAT_CLIENTES_MES_ANO(
    ANO,
    MES,
    MESNUM,
    CODCLI,
    FANTASIA,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF,
    MESBASE)
AS
select ANO, MES, MESNUM, codcli, fantasia, cast(SUM(valoricms) as numeric(14,2)), cast(SUM(valoripi) as numeric(14,2)), cast(SUM(valoritens) as numeric(14,2)), cast(SUM(valortotalnf) as numeric(14,2)), mes_ano from nf_fat_prod
GROUP BY ANO, MES, MESNUM, codcli, fantasia, mes_ano order by ANO, MESNUM, CODCLI
;



/* View: FAT_DEV_DIA */
CREATE VIEW FAT_DEV_DIA(
    MES_ANO,
    CODCLI,
    FANTASIA,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF,
    MES,
    ANO,
    MESNUM)
AS
select mes_ano, codcli, fantasia, SUM(valoricms), SUM(valoripi), SUM(valoritens), SUM(valortotalnf), mes, ano, mesnum from nf_dev_prod
GROUP BY mes_ano, codcli, fantasia, mes, ano ,mesnum order by codcli, MES_ANO
;



/* View: DEVOLUCOES_CLIENTE_MES */
CREATE VIEW DEVOLUCOES_CLIENTE_MES(
    ID,
    ANO,
    MES,
    MESNUM,
    CODCLI,
    FANTASIA,
    TOTAL,
    DEV,
    MESBASE)
AS
SELECT 1, a.ano, a.mes, a.mesnum, a.codcli, a.fantasia
, a.vr_nf, coalesce(b.vr_nf,0) as dev , a.mesbase
FROM fat_clientes_mes_ano a left join fat_dev_dia b
on (a.codcli = b.codcli and a.ano = b.ano and a.mesnum = b.mesnum)
where a.ano = 2015 order by a.codcli,  a.mesnum
;



/* View: DIVERGENCIA_ENTRADA */
CREATE VIEW DIVERGENCIA_ENTRADA(
    EMISSAO,
    SISTEMA,
    CODCLI,
    RAZAO,
    CPAG,
    NOSSOPED,
    PEDIDOCLI,
    STAEST,
    IDNUMNF,
    IDITEMNF,
    CODIGOITEM,
    DESCRICAO,
    QTDEITEM,
    VLNF,
    UNDNF,
    NUMPED,
    NFSAIDA,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    QTDEPED,
    QTDEENT,
    VLPED,
    SALDO,
    VLFATURAR,
    PRAZO,
    UNDPED,
    SEMANA,
    DIV_SEMPED,
    DIV_PRECO,
    DIV_UND,
    DIV_QTD,
    TOLRECEBIM)
AS
select  emissao, sistema, codcli, razao, cpag, nossoped, tbnfc.pedidocli, staest, idnumnf, iditemnf, codigoitem, descricao, qtdeitem, TBITENSNFC.vlunit, TBITENSNFC.und, numped, nfsaida,
iditem, idnumped, codprod, nomeprod, qtdeped, qtdeent, TBPROPITEMC.vlunit, saldo, vlfaturar, prazo, TBPROPITEMC.und, semana,
case
when idnumped is null then '1' else '0'
end,
case
when tbpropitemc.vlunit is null then '0'
when tbpropitemc.vlunit = tbitensnfc.vlunit then '0'
else '2'
end,
case
when tbpropitemc.und is null then '0'
when tbpropitemc.und = tbitensnfc.und then '0'
else '3'
end,
case
when qtdeent is null then '0'
when qtdeent > (qtdeped+(qtdeped*(tbparcompras.tolrecebim/100))) then '4'
else '0'
end, tbparcompras.tolrecebim 
from tbnfc left join tbitensnfc on (tbnfc.numnf = tbitensnfc.idnumnf) left join tbpropitemc on (tbitensnfc.iditemped = tbpropitemc.iditem), tbparcompras
;



/* View: SEM_FATURA2 */
CREATE VIEW SEM_FATURA2(
    NOTA_FISCAL,
    FORNECEDOR,
    SUBCFOP,
    GERA_FATURA,
    CFOP,
    DESCCFOP,
    EMISSAO,
    ENTRADA,
    VALOR)
AS
select tbnfc.pedidocli, tbnfc.razao, TBNFC.nfcfopi,
CASE WHEN TBCFOP.geradupl = 0 THEN 'S'
ELSE 'N'
end,   tbnfc.cfop, tbnfc.desccfop,
tbnfc.emissao, tbnfc.sistema, tbnfc.valortotalnf from tbnfc LEFT JOIN tbcfop ON (NFCFOPI = CFOPI)
;



/* View: DUPL_NF */
CREATE VIEW DUPL_NF(
    QTD,
    NOTA_FISCAL)
AS
select COUNT(NOTA_FISCAL), sem_fatura2.nota_fiscal FROM SEM_FATURA2 GROUP BY NOTA_FISCAL
;



/* View: ESTOQUE_PROCESSO */
CREATE VIEW ESTOQUE_PROCESSO(
    CODPROD,
    NOMEITEM,
    TIPO_ITEM,
    QTD_DEMANDA)
AS
select TB_OS.produto, tbitens.nomeitem, tbitens.tipoitem,   SUM(TB_OS.saldo) + SUM(TB_OS.total_terceiro) from tb_os
left join tbitens on (tb_os.produto = tbitens.codigoitem)
where TB_OS.status IN ('EM PROCESSO','EM TERCEIRO')
GROUP BY PRODUTO, tbitens.nomeitem, tbitens.tipoitem
;



/* View: PEDIDOC */
CREATE VIEW PEDIDOC(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    DESCONTOC,
    CFOPI,
    LIBENGEPED,
    PEDNOVO,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    TIPO_ITEM,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    UND,
    UND_ESTOQUE,
    FATOR_CONVITEM,
    SALDO_CONV,
    DESENHOITEM,
    REVDESENHOITEM,
    ET,
    SEMANA,
    ANOREF,
    APLICACAO,
    VTOTIPI,
    VORIPI,
    STPREV,
    MES,
    ULTIMA_NF,
    DATA_NF,
    QTD_NF,
    IE_ATRAZO,
    PT_IE,
    PROJETO,
    UNIDADE,
    COMPRADOR,
    DIMENSAO,
    PLANTA,
    TRIB_IPI)
AS
select
numped, codcli, fantasia, cpag, tbforender, tbforbairro, tbforcep, tbforcid, tbforest, tbforendercob, tbforbairrocob, tbforcepcob, tbforcidcob, tbforestcob, tbforenderent, tbforbairroent, tbforcepent, tbforcident, tbforestent, tbforcodtransp, tbfornometransp, tbpropc.status, tbpropc.cfop, tbpropc.desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbpropc.icms, tbpropc.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, razao,descontoc,tbpropc.cfopi,libengeped,pednovo,
iditem, idnumped, tbpropitemc.codprod, nomeprod, tbitens.tipoitem,  descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem,
case
when tbcfop.aliqipi = 1 then 0
else
tbitens.ipiitemvenda
end,
saldo, vlfaturar, prazo, pcp, prazopcp, posicao, opnum, pedidocli,und, TBITENS.undusoitem, TBITENS.fatorconvitem,
CASE WHEN TBITENS.fatorconvitem IS NULL THEN SALDO
ELSE
f_ROUND(SALDO * TBITENS.fatorconvitem)
END
, tbpropitemc.desenhoitem, tbpropitemc.revdesenhoitem, et, semana, anoref, aplicacao,
case (ipi*vlfaturar)
when 0 then 0 else
(ipi*vlfaturar)/100
end,
case (ipi*vlitem)
when 0 then 0 else
(ipi*vlitem)/100
end, tbpropitemc.status, upper(f_cmonthshortlang(prazo,'pt') || '/' || anoref),
ultima_nf, data_nf, qtd_nf, ie_atrazo,
    case
        when data_nf - prazo is null then 0
        when data_nf - prazo <= 0 then 0
        when data_nf - prazo between 1 and 5 then 2
        when data_nf - prazo > 5 then ((data_nf - prazo) - 5) + 2
        else 0
    end
,formaenv, tbpropc.unidade, tb_user.userlogin 
,
CASE
WHEN TBITENS.larguraitem > 0 then 'LARG.: ' || TBITENS.larguraitem 
ELSE ''
END
||
CASE
WHEN TBITENS.comprimitem > 0 then ' COMP.: ' || TBITENS.comprimitem
ELSE ''
END
||
CASE
WHEN TBITENS.espessuraitem > 0 then ' ESP.: ' || TBITENS.espessuraitem
ELSE ''
END, tbsetor.nomesetor, tbcfop.aliqipi
from tbpropc left join (tbpropitemc left join tbitens on (tbpropitemc.codprod = tbitens.codigoitem)
left join tbsetor on (tbpropitemc.posicao = tbsetor.idsetor)
) on (tbpropc.numped = tbpropitemc.idnumped) left join tb_user on (tbpropc.comissaorep
= tb_user.userid) left join tbcfop on (tbpropc.cfopi = tbcfop.cfopi)
;



/* View: PLANO_ENTREGA */
CREATE VIEW PLANO_ENTREGA(
    CODPROD,
    NOMEITEM,
    TIPO_ITEM,
    QTD_DEMANDA,
    SEMANA,
    ANOREF)
AS
select pedidoc.codprod,pedidoc.nomeprod , pedidoc.tipo_item ,  sum(saldo_CONV), semana, anoref
from pedidoc where saldo > 0 and semana <> '-' and pedidoc.stPREV = 0
and pedidoc.tipo_item in ('MAT�RIA-PRIMA','COMPONENTE COMPRADO')
group by pedidoc.codprod, pedidoc.nomeprod, pedidoc.tipo_item, semana, anoref
order by CODPROD, semana
;



/* View: EM_PROGRAMACAO */
CREATE VIEW EM_PROGRAMACAO(
    CODPROD,
    NOMEITEM,
    TIPO_ITEM,
    QTD_DEMANDA)
AS
select codprod, nomeitem, tipo_item, qtd_demanda
from estoque_processo
union all 
select codprod, nomeitem, tipo_item, qtd_demanda
from plano_entrega
;



/* View: SALDO_TERCEIRO */
CREATE VIEW SALDO_TERCEIRO(
    CODIGOMAT,
    OS,
    QTD_MOV,
    CODFOR,
    NOTA_SAIDA,
    QTDE_OS)
AS
select codigomat, os, sum(qtd_mov), codfor, nota_saida, tb_os.qtde_produzir
from tb_terceiro left join tb_os on tb_os.numero_os = tb_terceiro.os
group by 
CODIGOMAT,
OS,
CODFOR,
NOTA_SAIDA, tb_os.qtde_produzir
;



/* View: EM_TERCEIRO */
CREATE VIEW EM_TERCEIRO(
    IDLANC,
    DATALANC,
    CODIGOMAT,
    DOCTO,
    OS,
    QTD_MOV,
    UND,
    LOTE,
    NR,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_SAIDA,
    NOTA_ENTRADA,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    GRUPO,
    FANTASIA,
    SALDO,
    NOMEITEM,
    PESO_UNIT,
    PESO_TOTAL,
    QTDE_OS)
AS
select idlanc, datalanc, tb_terceiro.codigomat, docto, tb_terceiro.os, tb_terceiro.qtd_mov, und, lote, nr, cod_parametro, cfop, tb_terceiro.codfor, tb_terceiro.nota_saida, nota_entrada, mes_lanc, status, usuario, hora_lanc, grupo,
tbfor.tbforfan, saldo_terceiro.qtd_mov, tbitens.nomeitem, tbitens.pesoliqitem, tbitens.pesoliqitem * tb_terceiro.qtd_mov, saldo_terceiro.qtde_os
from tb_terceiro left join tbfor on (tb_terceiro.codfor = tbfor.tbforcod)
left join tbitens on (tb_terceiro.codigomat = tbitens.codigoitem)
/*left join saldo_terceiro on (tb_terceiro.codfor = saldo_terceiro.codfor and tb_terceiro.codigomat = saldo_terceiro.codigomat  and tb_terceiro.nota_saida = saldo_terceiro.nota_saida and tb_terceiro.os = saldo_terceiro.os)*/
left join saldo_terceiro on (tb_terceiro.codfor = saldo_terceiro.codfor and tb_terceiro.codigomat = saldo_terceiro.codigomat  and tb_terceiro.nota_saida = saldo_terceiro.nota_saida)
;



/* View: SALDO_TERCEIRONS */
CREATE VIEW SALDO_TERCEIRONS(
    CODIGOMAT,
    QTD_MOV,
    CODFOR,
    NOTA_SAIDA,
    QTDE_OS)
AS
select codigomat, sum(qtd_mov), codfor, nota_saida, 0
from tb_terceiro
group by 
CODIGOMAT,
CODFOR,
NOTA_SAIDA
;



/* View: EM_TERCEIRONS */
CREATE VIEW EM_TERCEIRONS(
    IDLANC,
    DATALANC,
    CODIGOMAT,
    DOCTO,
    OS,
    QTD_MOV,
    UND,
    LOTE,
    NR,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_SAIDA,
    NOTA_ENTRADA,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    GRUPO,
    FANTASIA,
    SALDO,
    NOMEITEM,
    PESO_UNIT,
    PESO_TOTAL,
    QTDE_OS)
AS
select idlanc, datalanc, tb_terceiro.codigomat, docto, tb_terceiro.os, tb_terceiro.qtd_mov, und, lote, nr, cod_parametro, cfop, tb_terceiro.codfor, tb_terceiro.nota_saida, nota_entrada, mes_lanc, status, usuario, hora_lanc, grupo,
tbfor.tbforfan, saldo_terceirons.qtd_mov, tbitens.nomeitem, tbitens.pesoliqitem, tbitens.pesoliqitem * tb_terceiro.qtd_mov, saldo_terceirons.qtde_os
from tb_terceiro left join tbfor on (tb_terceiro.codfor = tbfor.tbforcod)
left join tbitens on (tb_terceiro.codigomat = tbitens.codigoitem)
left join saldo_terceirons on (tb_terceiro.codfor = saldo_terceirons.codfor and tb_terceiro.codigomat = saldo_terceirons.codigomat  and tb_terceiro.nota_saida = saldo_terceirons.nota_saida)
;



/* View: EM_TERCEIROS */
CREATE VIEW EM_TERCEIROS(
    IDLANC,
    DATALANC,
    CODIGOMAT,
    DOCTO,
    OS,
    QTD_ENV,
    QTD_REC,
    UND,
    LOTE,
    NR,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_SAIDA,
    NOTA_ENTRADA,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    GRUPO,
    FANTASIA,
    SALDO,
    NOMEITEM,
    PESO_UNIT,
    PESO_TOTAL,
    QTDE_OS)
AS
select idlanc, datalanc, tb_terceiro.codigomat, docto, tb_terceiro.os,
CASE WHEN tb_terceiro.qtd_mov > 0
THEN TB_TERCEIRO.qtd_mov
ELSE 0
END,
CASE WHEN tb_terceiro.qtd_mov < 0
THEN TB_TERCEIRO.qtd_mov
ELSE 0
END,
und, lote, nr, cod_parametro, cfop, tb_terceiro.codfor, tb_terceiro.nota_saida, nota_entrada, mes_lanc, status, usuario, hora_lanc, grupo,
tbfor.tbforfan, saldo_terceiro.qtd_mov, tbitens.nomeitem, tbitens.pesoliqitem, tbitens.pesoliqitem * tb_terceiro.qtd_mov, saldo_terceiro.qtde_os
from tb_terceiro left join tbfor on (tb_terceiro.codfor = tbfor.tbforcod)
left join tbitens on (tb_terceiro.codigomat = tbitens.codigoitem)
left join saldo_terceiro on (tb_terceiro.codfor = saldo_terceiro.codfor and tb_terceiro.codigomat = saldo_terceiro.codigomat  and tb_terceiro.nota_saida = saldo_terceiro.nota_saida and tb_terceiro.os = saldo_terceiro.os)
;



/* View: EM_TERCEIROSNS */
CREATE VIEW EM_TERCEIROSNS(
    IDLANC,
    DATALANC,
    CODIGOMAT,
    DOCTO,
    OS,
    QTD_ENV,
    QTD_REC,
    UND,
    LOTE,
    NR,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_SAIDA,
    NOTA_ENTRADA,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    GRUPO,
    FANTASIA,
    SALDO,
    NOMEITEM,
    PESO_UNIT,
    PESO_TOTAL,
    QTDE_OS)
AS
select idlanc, datalanc, tb_terceiro.codigomat, docto, tb_terceiro.os,
CASE WHEN tb_terceiro.qtd_mov > 0
THEN TB_TERCEIRO.qtd_mov
ELSE 0
END,
CASE WHEN tb_terceiro.qtd_mov < 0
THEN TB_TERCEIRO.qtd_mov
ELSE 0
END,
und, lote, nr, cod_parametro, cfop, tb_terceiro.codfor, tb_terceiro.nota_saida, nota_entrada, mes_lanc, status, usuario, hora_lanc, grupo,
tbfor.tbforfan, saldo_terceirons.qtd_mov, tbitens.nomeitem, tbitens.pesoliqitem, tbitens.pesoliqitem * tb_terceiro.qtd_mov, saldo_terceirons.qtde_os
from tb_terceiro left join tbfor on (tb_terceiro.codfor = tbfor.tbforcod)
left join tbitens on (tb_terceiro.codigomat = tbitens.codigoitem)
/*left join saldo_terceiro on (tb_terceiro.codfor = saldo_terceiro.codfor and tb_terceiro.codigomat = saldo_terceiro.codigomat  and tb_terceiro.nota_saida = saldo_terceiro.nota_saida and tb_terceiro.os = saldo_terceiro.os)*/
left join saldo_terceirons on (tb_terceiro.codfor = saldo_terceirons.codfor and tb_terceiro.codigomat = saldo_terceirons.codigomat  and tb_terceiro.nota_saida = saldo_terceirons.nota_saida)
;



/* View: ENTRADA_EMBALAGEM */
CREATE VIEW ENTRADA_EMBALAGEM(
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    FANTASIA,
    CODIGOITEM,
    DESCRICAO,
    ENVIO,
    RETORNO,
    UND,
    VLUNIT,
    VLITEM,
    NF_NUMERO)
AS
select
sistema, codcli,NFCFOPI,CFOP,DESCCFOP, fantasia,
codigoitem,DESCRICAO, 0, qtdeitem, und, vlunit, vlitem, cast(tbnfc.pedidocli as numeric(12,0))
from tbnfc join tbitensnfc on (numnf = idnumnf) where cfop in ('1.920','2.920','1.921','2.921')
and sistema >= '01.01.2010'
order by codcli, codigoitem, sistema
;



/* View: ENTRADA_MP */
CREATE VIEW ENTRADA_MP(
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    FANTASIA,
    CODIGOITEM,
    DESCRICAO,
    QTDE,
    UND,
    VLUNIT,
    VLITEM,
    NF_NUMERO,
    NOSSA_NF)
AS
select
sistema, codcli,NFCFOPI,'E',DESCCFOP, fantasia,
codigoitem,DESCRICAO, qtdeitem, und, vlunit, vlitem, cast(tbnfc.pedidocli as numeric(12,0)), 0
from tbnfc join tbitensnfc on (numnf = idnumnf) where cfop in ('1.901','2.901')
and sistema >= '01.01.2013'
order by codcli, codigoitem, sistema
;



/* View: ENTRADAS */
CREATE VIEW ENTRADAS(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    PEDIDOCLI,
    STAEST,
    IDITEMPED,
    CODIGOITEM,
    QTDEITEM,
    NUMPED,
    VLUNIT,
    VLITEM,
    UND)
AS
select a.idlanc, a.datalanc, a.datasis, a.codfor, a.nota_fiscal, 'S',
a.iditemped, a.codigomat, a.qtdentrada, a.idpedido ,a.valorlanc, a.qtdentrada*a.valorlanc, a.und  from tblanc a
;



/* View: ENTRADAS_ESTOQUE */
CREATE VIEW ENTRADAS_ESTOQUE(
    CODIGOMAT,
    QTDENTRADA,
    MES_LANC,
    VALOR_TOTAL,
    TIPO_ITEM,
    UND)
AS
select codigomat, sum(qtd_mov), mes_lanc, cast(sum(valor_mov)as digito16), movimento_recebido.tipo_item, movimento_recebido.und
from movimento_recebido where grupo in(0,1) group by codigomat, mes_lanc, tipo_item, movimento_recebido.und
having (f_stringlength(codigomat) > 1 and tipo_item in ('PRODUTO ACABADO', 'COMPONENTE FABRICADO')
and sum(qtd_mov)<>0
 ) order by codigomat
;



/* View: ENTRADAS_INCON */
CREATE VIEW ENTRADAS_INCON(
    ID,
    EMISSAO,
    ENTRADA,
    CODCLI,
    RAZAO,
    CNPJCLI,
    INSCCLI,
    CFOP,
    DESCCFOP,
    NOSSOPED,
    NOTA_FORNECEDOR,
    SUB_CFO)
AS
select numnf, emissao, sistema, codcli, razao, cnpjcli, insccli, cfop, desccfop, nossoped, pedidocli, nfcfopi
from tbnfc
where sistema >= '01.05.2008' and cfop = '-'
;



/* View: ENTRADAS_TOTAL */
CREATE VIEW ENTRADAS_TOTAL(
    CODIGOMAT,
    QTD_MOV,
    VALOR_MOV,
    TIPO_ITEM)
AS
select notasfiscaisc.codigoitem , SUM(notasfiscaisc.qtdeitem), SUM(notasfiscaisc.vlitem), notasfiscaisc.tipo_item 
from notasfiscaisc where notasfiscaisc.tipo_item = 'COMPONENTE COMPRADO' AND notasfiscaisc.sistema >= '01.01.2011'
AND notasfiscaisc.status = 0
GROUP BY codigoitem, notasfiscaisc.tipo_item
;



/* View: ENTRADASCFOP */
CREATE VIEW ENTRADASCFOP(
    CFOP,
    DESCCFOP,
    ENTRADA,
    EMISSAO,
    NOTAFISCAL,
    FORNECEDOR,
    VALORITENS,
    BASEICMS,
    ALIQICMS,
    VALORICMS,
    BASEICMSSUBST,
    VALORICMSSUBST,
    ALIQIPI,
    VALORIPI,
    VALORFRETE,
    VALORSERVICO,
    VALORSEGURO,
    OUTRSDESPESAS,
    VALORTOTAL,
    REGISTRADA)
AS
select a.cfop, a.desccfop, a.sistema, a.emissao,  a.pedidocli, a.razao, a.valoritens, a.baseicms, a.icms, a.valoricms,
a.baseicmssubst, a.valoricmssubst, f_round((a.valoripi/a.valoritens)*100), a.valoripi, a.valorfrete, a.valorservico,
a.valorseguro, a.outrasdepesas, a.valortotalnf,
case when a.staest = 1 then 'S'
else 'N'
end
from tbnfc a
where a.sistema >= '01.01.2012'
;



/* View: ENTREGAS */
CREATE VIEW ENTREGAS(
    NUMPED,
    DOCTO,
    CODIGO_PROD,
    DESCR,
    QTDE_PED,
    PRAZO_ENT,
    QTDE_ENT,
    DATA_ENT,
    CODFOR,
    FORNECEDOR,
    TIPO_R)
AS
select  idnumped,null, codprod, nomeprod, qtdeped, prazo,0,NULL, tbpropc.codcli, tbpropc.fantasia, 0
from tbpropc join tbpropitemc on (numped = idnumped)
where prazo is not null and qtdeped > 0
order by tbpropc.codcli, codprod, prazo
;



/* View: ESPESSURA_MAX_ET */
CREATE VIEW ESPESSURA_MAX_ET(
    ET,
    TIPO,
    CODIGO,
    CARACTERISTICA,
    DIMENSAO,
    TOLMAX,
    TOLMIN,
    ACRESCIMO)
AS
select
ET, TIPO, CODIGO, CARACTERISTICA, DIMENSAO, TOLMAX, TOLMIN,
CASE
WHEN f_left(tolmax,1) = '+' then f_replace(TOLMAX,'+','')
WHEN f_left(tolmin,1) = '+' then f_replace(TOLmin,'+','')
when tolmax = '-' and tolmin = '-' then 0
end
from tbet JOIN TBETITEM ON(ET=IDET) WHERE (CARACTERISTICA = 'ESPESSURA'
AND TIPO = 'MP')
;



/* View: ESTATISTICA_FATURAMENTO */
CREATE VIEW ESTATISTICA_FATURAMENTO(
    DOCTO,
    CODCLI,
    FANTASIA,
    CODPROD,
    NOMEPROD,
    QTDEPED,
    VLUNIT,
    VLTOTAL,
    DIA,
    PEDIDOCLI,
    DESENHOITEM,
    SEMANA,
    ANO,
    STATUS,
    MES)
AS
select nf_numero, codcli, fantasia,
codigoitem, descricao, qtdeitem, cast(vlunit/notas.fconv as numeric(12,6)),cast((vlunit/fconv)*QTDEITEM as numeric(12,6)), f_padleft(f_dayofmonth(emissao),'0',2) ,
pedidocli, desenho, f_padleft(f_weekofyear(emissao),'0',2)  , f_year(emissao) , 'REAL', f_padleft(f_month(emissao),'0',2)
from notas
where emissao >='01.02.2010' AND stacom in (0,4)
and canc = 'N'
;



/* View: ESTATISTICA_VENDAS */
CREATE VIEW ESTATISTICA_VENDAS(
    DOCTO,
    CODCLI,
    FANTASIA,
    CODPROD,
    NOMEPROD,
    QTDEPED,
    VLUNIT,
    VLTOTAL,
    DIA,
    PEDIDOCLI,
    DESENHOITEM,
    SEMANA,
    ANO,
    STATUS,
    MES)
AS
select numped, codcli, fantasia,
codprod, nomeprod, qtdeped, cast(vlunit/pedido.fcvenda as numeric(12,6)) ,cast(qtdeped*(vlunit/fcvenda) as numeric(12,6)),f_padleft(f_dayofmonth(prazo),'0',2),
pedidocli, desenhoitem, semana, anoref,
CASE
WHEN stprev = 0 THEN 'FIRME'
WHEN stprev = 1 then 'PREV'
END, f_left(mesbase,2)
from pedido
where prazo >='01.01.2010' AND stprev in (0,1)
;



/* View: ESTATISTICA_GERAL */
CREATE VIEW ESTATISTICA_GERAL(
    DOCTO,
    CODCLI,
    FANTASIA,
    CODPROD,
    NOMEPROD,
    QTDEPED,
    VLUNIT,
    VLTOTAL,
    DIA,
    PEDIDOCLI,
    DESENHOITEM,
    SEMANA,
    ANO,
    MES,
    STATUS)
AS
select docto, codcli, fantasia, codprod, nomeprod, qtdeped, vlunit,vltotal, dia, pedidocli, desenhoitem, semana, ano, mes, status
from estatistica_vendas UNION
select docto, codcli, fantasia, codprod, nomeprod, qtdeped, vlunit, vltotal,dia, pedidocli, desenhoitem, semana, ano, mes, status
from estatistica_faturamento
;



/* View: ETIQUETAS_LOTE */
CREATE VIEW ETIQUETAS_LOTE(
    ID_ETIQUETA,
    QTDE,
    LOTE,
    LOCAL,
    EMBALAGEM,
    QTD_EMBALAGENS,
    PESO_BRUTO,
    PESO_LIQ,
    CODIGOITEM,
    QTDETOTAL,
    SALDOLOTE,
    POSICAO,
    ENTRADA,
    CODFOR,
    NOTA_FISCAL,
    TIPO,
    OS,
    TBFORFAN,
    NOMEITEM,
    UND,
    COMPRIM,
    LARGURA,
    ESPESSURA,
    TIPO_ITEM,
    ORIGEM,
    QTDE_RESERV,
    IDREC,
    IDSETOR,
    NOMEREC,
    NOMESETOR,
    OS_DESTINO,
    VALIDADE)
AS
select id_etiqueta, qtde, tb_etiqueta_lote.lote, local, embalagem, qtd_embalagens, peso_bruto, peso_liq,
codigoitem, qtdetotal, saldolote, posicao, entrada, codfor, nota_fiscal, cs_lotes.tipo, os, tbforfan, nomeitem, und, comprim, cs_lotes.largura, espessura, tipo_item, origem, qtde_reserv, tb_etiqueta_lote.idrec, tb_etiqueta_lote.idsetor,
tbrecurso.nomerec, tbsetor.nomesetor, tb_etiqueta_lote.os_destino, cs_lotes.validade 
from tb_etiqueta_lote left join cs_lotes on (tb_etiqueta_lote.lote = cs_lotes.lote)
left join tbrecurso on (tb_etiqueta_lote.idrec = tbrecurso.idrec) left join tbsetor on (tb_etiqueta_lote.idsetor = tbsetor.idsetor)
order by id_etiqueta
;



/* View: ESTOQUE_A_VISTA */
CREATE VIEW ESTOQUE_A_VISTA(
    LOTE,
    CODFOR,
    NOMEFOR,
    CODIGOITEM,
    ESTOQUE_FIS,
    ENDERECO,
    SETOR,
    LINHA,
    COLUNA,
    ESTOQUE_DISP,
    ESTOQUE_RES,
    NOTA_FISCAL,
    ENTRADA,
    STATUS,
    UND,
    VALIDADE)
AS
select etiquetas_lote.lote, etiquetas_lote.codfor, etiquetas_lote.tbforfan, etiquetas_lote.codigoitem,
sum(etiquetas_lote.qtde), etiquetas_lote.idrec , etiquetas_lote.idsetor, f_right(idrec,2), f_mid(idrec,3,2),
etiquetas_lote.saldolote, etiquetas_lote.qtde_reserv, etiquetas_lote.nota_fiscal, etiquetas_lote.entrada,
etiquetas_lote.posicao, etiquetas_lote.und, etiquetas_lote.validade 
from etiquetas_lote where idsetor = '845' and f_stringlength(idrec) > 0
group by
etiquetas_lote.lote, etiquetas_lote.codfor, etiquetas_lote.tbforfan, etiquetas_lote.codigoitem,
etiquetas_lote.idrec , etiquetas_lote.idsetor, f_right(idrec,2), f_mid(idrec,3,2),
etiquetas_lote.saldolote, etiquetas_lote.qtde_reserv, etiquetas_lote.nota_fiscal, etiquetas_lote.entrada,
etiquetas_lote.posicao, etiquetas_lote.und, etiquetas_lote.validade
;



/* View: ESTRUTURA_MATERIAIS */
CREATE VIEW ESTRUTURA_MATERIAIS(
    PRODUTO,
    NOME,
    DESENHO,
    NIVEL_01,
    NOME_01,
    QTD_01,
    UND_01,
    TIPO_01,
    DIM_01,
    NIVEL_02,
    NOME_02,
    QTD_02,
    UND_02,
    TIPO_02,
    DIM_02,
    NIVEL_03,
    NOME_03,
    QTD_03,
    UND_03,
    TIPO_03,
    DIM_03,
    NIVEL_04,
    NOME_04,
    QTD_04,
    UND_04,
    TIPO_04,
    DIM_04,
    NIVEL_05,
    NOME_05,
    QTD_05,
    UND_05,
    TIPO_05,
    DIM_05,
    NIVEL_06,
    NOME_06,
    QTD_06,
    UND_06,
    TIPO_06,
    DIM_06,
    NIVEL_07,
    NOME_07,
    QTD_07,
    UND_07,
    TIPO_07,
    DIM_07,
    NIVEL_08,
    NOME_08,
    QTD_08,
    UND_08,
    TIPO_08,
    DIM_08,
    NIVEL_09,
    NOME_09,
    QTD_09,
    UND_09,
    TIPO_09,
    DIM_09,
    NIVEL_10,
    NOME_10,
    QTD_10,
    UND_10,
    TIPO_10,
    DIM_10,
    NIVEL_11,
    NOME_11,
    QTD_11,
    UND_11,
    TIPO_11,
    DIM_11,
    NIVEL_12,
    NOME_12,
    QTD_12,
    UND_12,
    TIPO_12,
    DIM_12)
AS
SELECT A.PAI, a.nome, a.desenhoitem,
A.FILHO, a.nome_filho,  A.QTD, A.UND, a.tipoitem ,A.medidas ,
B.FILHO,b.nome_filho , B.QTD,B.UND, b.tipoitem ,b.medidas ,
C.FILHO,c.nome_filho,  C.QTD,C.UND,c.tipoitem ,c.medidas ,
d.filho,d.nome_filho,  d.qtd,d.und,d.tipoitem ,d.medidas ,
e.filho,e.nome_filho,   e.qtd,e.und,e.tipoitem ,e.medidas ,
f.filho,f.nome_filho , f.qtd,f.und,f.tipoitem ,f.medidas ,
g.filho,g.nome_filho , g.qtd,g.und,g.tipoitem ,g.medidas ,
h.filho,h.nome_filho , h.qtd,h.und,h.tipoitem ,h.medidas ,
i.filho,i.nome_filho , i.qtd,i.und,i.tipoitem ,i.medidas ,
j.filho,j.nome_filho , j.qtd,j.und,j.tipoitem ,j.medidas ,
k.filho,k.nome_filho , k.qtd,k.und,k.tipoitem ,k.medidas ,
l.filho,l.nome_filho , l.qtd,l.und,l.tipoitem ,l.medidas 
FROM composicao_produto A left join
(composicao_produto B left join
(composicao_produto C left join
(composicao_produto D left join
(composicao_produto E left join
(composicao_produto F left join
(composicao_produto G left join
(composicao_produto H left join
(composicao_produto I left join
(composicao_produto J left join
(composicao_produto K left join composicao_produto L on k.filho = L.pai) on j.filho = k.pai)  on i.filho = j.pai) on h.filho = i.pai) on g.filho = h.pai)  on f.filho = g.pai) on e.filho = f.pai) on d.filho = e.pai) on c.filho = d.pai) on b.filho = c.pai)
on a.filho = b.pai ORDER BY A.PAI
;



/* View: ESTRUTURA_MATERIAIS_VERTICAL */
CREATE VIEW ESTRUTURA_MATERIAIS_VERTICAL(
    PRODUTO,
    NOME,
    NIVEL,
    CODIGO,
    TIPO,
    DESCRICAO,
    DIMENSAO,
    CONSUMO,
    UND)
AS
select a.produto, a.nome,1, a.nivel_01,a.tipo_01, a.nome_01,a.dim_01,sum(a.qtd_01), a.und_01
from estrutura_materiais a where a.nivel_01 is not null
group by a.produto, a.nome,1, a.nivel_01,a.tipo_01, a.nome_01,a.dim_01, a.und_01
union all
select b.produto, b.nome,2, b.nivel_02,b.tipo_02, b.nome_02,b.dim_02,sum(b.qtd_02), b.und_02
from estrutura_materiais b where b.nivel_02 is not null
group by b.produto, b.nome,2, b.nivel_02,b.tipo_02, b.nome_02,b.dim_02, b.und_02
union all
select c.produto, c.nome,3, c.nivel_03,c.tipo_03, c.nome_03,c.dim_03,sum(c.qtd_03), c.und_03
from estrutura_materiais c where c.nivel_03 is not null
group by c.produto, c.nome,3, c.nivel_03,c.tipo_03, c.nome_03,c.dim_03,c.und_03
union all
select d.produto, d.nome,4, d.nivel_04,d.tipo_04, d.nome_04,d.dim_04,sum(d.qtd_04), d.und_04
from estrutura_materiais d where d.nivel_04 is not null
group by d.produto, d.nome,4, d.nivel_04,d.tipo_04, d.nome_04,d.dim_04,d.und_04
;



/* View: ESTRUTURA_MATERIAIS_VERTICAL_2 */
CREATE VIEW ESTRUTURA_MATERIAIS_VERTICAL_2(
    PRODUTO,
    NOME,
    NIVEL,
    CODIGO,
    TIPO,
    DESCRICAO,
    DIMENSAO,
    CONSUMO,
    UND)
AS
select a.produto, a.nome,'05', a.nivel_05,a.tipo_05, a.nome_05,a.dim_05,a.qtd_05, a.und_05
from estrutura_materiais a
union all
select b.produto, b.nome,'06', b.nivel_06,b.tipo_06, b.nome_06,b.dim_06,b.qtd_06, b.und_06
from estrutura_materiais b union all
select c.produto, c.nome,'07', c.nivel_07,c.tipo_07, c.nome_07,c.dim_07,c.qtd_07, c.und_07
from estrutura_materiais c union all
select d.produto, d.nome,'08', d.nivel_08,d.tipo_08, d.nome_08,d.dim_08,d.qtd_08, d.und_08
from estrutura_materiais d
;



/* View: ESTRUTURAS_ITENS */
CREATE VIEW ESTRUTURAS_ITENS(
    ID,
    USUARIO,
    CODIGO,
    NIVEL,
    NOME,
    SEQ,
    COMPONENTE,
    CONSUMO_UNIT,
    CONSUMO_TOT,
    SETOR,
    NOME_SETOR,
    PCS_HORA,
    SETUP_HORA,
    CARGA_HS,
    ARVORE,
    PRODUTO,
    NOME_PRODUTO,
    TIPO_EST,
    UND,
    LOTE,
    IDPROC,
    IDMAT,
    UND_POR,
    TIPOMP,
    CALCULO,
    VR_UNIT,
    CUSTO_MAT,
    CUSTO_TRAT,
    CUSTO_PROC_MAQ,
    CUSTO_PROC_MO,
    CUSTO_APOIO,
    CUSTO_ITEM,
    CUSTO_IMPORT_ITEM,
    CUSTO_ACUM,
    CONSUMO_EXEC,
    CONSUMO_CANC,
    CONSUMO_SALDO,
    CONSUMO_RES,
    CONSUMO_REQ,
    REQ_N,
    DATA_INICIO,
    DATA_TERMINO,
    CARGA_EXEC,
    CARGA_SALDO,
    OBS_MAT,
    OBS_PROC,
    N_OS,
    REC_1,
    REC_2,
    REC_3,
    CUSTO_OPER,
    CUSTO_OS,
    CUSTO_REAL,
    PEDCOMPRA_N,
    STATUS_OS,
    DATA_INC,
    DATA_LIB,
    DATA_PROD,
    DATA_FAT,
    TIPO_OS,
    PED_VENDA,
    ID_PED_VENDA,
    IDPAI,
    TEMPO_HORA,
    RECURSO1,
    RECURSO2,
    RECURSO3)
AS
select a.id, a.usuario, a.codigo, a.nivel, a.nome, a.seq, a.componente, a.consumo_unit, a.consumo_tot, a.setor, a.nome_setor, a.pcs_hora, a.setup_hora, a.carga_hs, a.arvore, a.produto, a.nome_produto, a.tipo_est, a.und, a.lote, a.idproc, a.idmat, a.und_por, a.tipomp, a.calculo, a.vr_unit, a.custo_mat, a.custo_trat, a.custo_proc_maq, a.custo_proc_mo, a.custo_apoio, a.custo_item, a.custo_import_item, a.custo_acum, a.consumo_exec, a.consumo_canc, a.consumo_saldo, a.consumo_res, a.consumo_req, a.req_n, a.data_inicio, a.data_termino, a.carga_exec, a.carga_saldo, a.obs_mat, a.obs_proc, a.n_os, a.rec_1, a.rec_2, a.rec_3, a.custo_oper, a.custo_os, a.custo_real, a.pedcompra_n, a.status_os,
a.data_inc, a.data_lib, a.data_prod, a.data_fat, a.tipo_os, a.ped_venda, a.id_ped_venda, a.idpai, a.tempo_hora,
b.nomerec, c.nomerec, d.nomerec
from estrut_prod a left join tbrecurso b on (rec_1 = b.idrec) left join tbrecurso c
on (rec_2 = c.idrec) left join tbrecurso d on (rec_3 = d.idrec)
;



/* View: VIEW_ITENS */
CREATE VIEW VIEW_ITENS(
    CODIGO,
    NOMEITEM,
    DESENHOITEM,
    SUBGRUPO,
    CLIENTE,
    PESO_LIQ)
AS
select a.codigoitem, a.nomeitem, a.desenhoitem, a.subgrupo, b.descsubgrupo, A.pesoliqitem from tbitens a
left join tbsubgrupo b on (a.subgrupo = b.subgrupo)
;



/* View: ETIQUETA_EXPEDICAO */
CREATE VIEW ETIQUETA_EXPEDICAO(
    ORDEM,
    CODIGO,
    DESENHO,
    CLIENTE,
    DESCRICAO,
    SUBGRUPO,
    PESO_LIQ)
AS
select a.numof, a.produto, b.desenhoitem, b.cliente, b.nomeitem, b.subgrupo, B.peso_liq from tb_of a
left join view_itens b on (a.produto = b.codigo) where a.numof < 9999
;



/* View: ETIQUETA_MP */
CREATE VIEW ETIQUETA_MP(
    PRODUTO,
    SALDO,
    TIPO,
    VRUNIT,
    MES,
    ANO,
    STATUS)
AS
select produto, SUM(saldo), tipo, vrunit, '11', '2008', 'SALDO FINAL'
from tb_inv_est GROUP BY  produto, tipo, vrunit
HAVING (TIPO = 0)
;



/* View: ETIQUETAS_D */
CREATE VIEW ETIQUETAS_D(
    SERIE,
    DATA_MONTAGEM,
    ANO,
    DIA,
    PARTNUMBER,
    N_OS,
    DESCRICAO)
AS
select f_padleft(tb_etiquetas_pecas_d.id,'0',5), tb_os.data, f_padleft(f_year(tb_os.data),'0',2), f_padleft(f_dayofyear(tb_os.data),'0',3),
tbitens.desenhoitem, tb_etiquetas_pecas_d.os, tbitens.nomeitem from tb_etiquetas_pecas_d
left join (tb_os left join tbitens on tb_os.produto = tbitens.codigoitem) on (tb_etiquetas_pecas_d.os = tb_os.numero_os)
order by tb_etiquetas_pecas_d.id
;



/* View: ETIQUETAS_LOTE1 */
CREATE VIEW ETIQUETAS_LOTE1(
    ID_ETIQUETA,
    QTDE,
    LOTE,
    LOCAL,
    EMBALAGEM,
    QTD_EMBALAGENS,
    PESO_BRUTO,
    PESO_LIQ,
    IDREC,
    IDSETOR,
    OS_DESTINO,
    CODIGO_CLIENTE,
    PRODUTO,
    NUM_PEDIDO,
    DESENHOITEM,
    CODFATURAMITEM,
    NOMEITEM,
    UNDITEM,
    RAZAO,
    CODIGO_FORNECEDOR,
    ENDERECO,
    END_NUMERO,
    BAIRRO,
    CEP,
    CIDADE,
    UF,
    SEQUENCIA,
    NOTA_FISCAL,
    QTDE_NUMERICA,
    QTDE_FORMATADA,
    CODIGO_AUXILIAR,
    REVISAO)
AS
select a.id_etiqueta, F_PADLEFT(cast(a.qtde as numeric(15,0)),'0',6), a.lote, a.local, a.embalagem, a.qtd_embalagens, a.peso_bruto, a.peso_liq,
a.idrec, a.idsetor, F_PADLEFT(a.os_destino,'0',10), b.codigo_cliente, b.produto, b.num_pedido,
case when f_stringlength(c.desenhoitem) = 9 and d.tbforfan like 'SIMOLDES%'
then f_left(c.codfaturamitem, 3)||'.'|| f_mid(c.codfaturamitem,3,3)||'.'||f_right(c.codfaturamitem,3)
else
c.codfaturamitem
end   , c.codfaturamitem, c.nomeitem, c.undusoitem,  d.tbforraz, f_padleft(d.tbforcodant,'0',8),
d.tbforender, d.endereco_numero, d.tbforbairro, d.tbforcep, d.tbforcid, d.tbforest, f_padleft(a.sequencia,'0',3), f_padleft(a.nota_fiscal,'0',9),
a.qtde, f_padleft( f_replace(cast(a.qtde as numeric(15,2)),'.',''),'0',8), c.grupocontab, C.revdesenhoitem
from tb_etiqueta_lote1 a left join (tb_os b left join tbitens c on (b.produto = c.codigoitem) left join tbfor d on (b.codigo_cliente=d.tbforcod)) on (a.os_destino = b.numero_os)
order by id_etiqueta
;



/* View: ETIQUETAS_LOTE2 */
CREATE VIEW ETIQUETAS_LOTE2(
    ID_ETIQUETA,
    QTDE,
    LOTE,
    LOCAL,
    EMBALAGEM,
    QTD_EMBALAGENS,
    PESO_BRUTO,
    PESO_LIQ,
    IDREC,
    IDSETOR,
    OS_DESTINO,
    CODIGO_CLIENTE,
    PRODUTO,
    NUM_PEDIDO,
    DESENHOITEM,
    CODFATURAMITEM,
    NOMEITEM,
    UNDITEM,
    RAZAO,
    CODIGO_FORNECEDOR,
    ENDERECO,
    END_NUMERO,
    BAIRRO,
    CEP,
    CIDADE,
    UF,
    SEQUENCIA,
    NOTA_FISCAL,
    QTDE_NUMERICA,
    QTDE_FORMATADA,
    CODIGO_AUXILIAR,
    REVISAO,
    LOTE_CLIENTE)
AS
select a.id_etiqueta, F_PADLEFT(cast(a.qtde as numeric(15,0)),'0',5), a.lote, a.local, a.embalagem, a.qtd_embalagens, a.peso_bruto, a.peso_liq,
a.idrec, a.idsetor, f_padleft(a.os_destino,'0',10), b.codigo_cliente, b.produto, b.num_pedido,
case when f_stringlength(c.desenhoitem) = 9
then f_left(c.codfaturamitem, 3)||'.'|| f_mid(c.codfaturamitem,3,3)||'.'||f_right(c.codfaturamitem,3)
else
c.codfaturamitem
end   , f_padright(c.codfaturamitem,' ',25), c.nomeitem, c.undusoitem,  d.tbforraz, d.tbforcodant,
d.tbforender, d.endereco_numero, d.tbforbairro, d.tbforcep, d.tbforcid, d.tbforest, f_padleft(a.sequencia,'0',3), f_padleft(a.nota_fiscal,'0',6),
a.qtde, f_padleft( f_replace(cast(a.qtde as numeric(15,2)),'.',''),'0',8), c.grupocontab, f_padright(f_replace(C.revdesenhoitem,'-',''),' ',10), f_padright(f.posicao,' ',12)
from tb_etiqueta_lote1 a left join (tb_os b left join tbitens c on (b.produto = c.codigoitem) left join tbfor d on (b.codigo_cliente=d.tbforcod)) on (a.os_destino = b.numero_os)
left join (notas e left join tbpropitem f on (e.iditemped = f.iditem)) on (a.nota_fiscal = e.nf_numero and b.produto = e.codigoitem)
order by id_etiqueta
;



/* View: ETIQUETAS_NF */
CREATE VIEW ETIQUETAS_NF(
    ID_ETIQUETA,
    QTDE,
    LOTE,
    LOCAL,
    EMBALAGEM,
    QTD_EMBALAGENS,
    PESO_BRUTO,
    PESO_LIQ,
    IDREC,
    IDSETOR,
    OS_DESTINO,
    CODIGO_CLIENTE,
    PRODUTO,
    NUM_PEDIDO,
    DESENHOITEM,
    CODFATURAMITEM,
    NOMEITEM,
    UNDITEM,
    RAZAO,
    CODIGO_FORNECEDOR,
    ENDERECO,
    END_NUMERO,
    BAIRRO,
    CEP,
    CIDADE,
    UF,
    SEQUENCIA,
    NOTA_FISCAL,
    QTDE_NUMERICA,
    QTDE_FORMATADA,
    CODIGO_AUXILIAR,
    REVISAO,
    LOTE_CLIENTE)
AS
select a.iditemnf, F_PADLEFT(cast(a.qtdeitem as numeric(15,0)),'0',5), '20140210', '', '', '', 0, 0,
0, 0, '0020140210', a.codcli, a.codigoitem, a.pedidocli,
c.desenhoitem
, f_padright(c.codfaturamitem,' ',25), c.nomeitem, c.undusoitem,  d.tbforraz, d.tbforcodant,
d.tbforender, d.endereco_numero, d.tbforbairro, d.tbforcep, d.tbforcid, d.tbforest, '001', f_padleft(a.nf_numero,'0',6),
a.qtdeitem, f_padleft(f_replace(cast(a.qtdeitem as numeric(15,2)),'.',''),'0',8), c.grupocontab, f_padright(f_replace(C.revdesenhoitem,'-',''),' ',10), 'DANKAKU    '
from notas a left join tbitens c on (a.codigoitem = c.codigoitem) left join tbfor d on (a.codcli=d.tbforcod)
order by a.iditemnf
;



/* View: ETIQUETAS_RD */
CREATE VIEW ETIQUETAS_RD(
    SERIE,
    DATA_MONTAGEM,
    ANO,
    DIA,
    PARTNUMBER,
    N_OS,
    DESCRICAO,
    REFERENCIA,
    ID)
AS
select f_padleft(tb_etiquetas_pecas_d.id,'0',4), tb_os.data, f_right(f_year(tb_os.data),2), f_padleft(f_dayofyear(tb_os.data),'0',3),
tbitens.desenhoitem, tb_etiquetas_pecas_d.os, tbitens.nomeitem,
case
when tbitens.desenhoitem = 'BA1016118' THEN 'AR'
when tbitens.desenhoitem = 'BA1016259' THEN 'AU'
when tbitens.desenhoitem = 'BA1016117' THEN 'AL'
when tbitens.desenhoitem = 'BA1501400' THEN 'SC'
when tbitens.desenhoitem = 'BA1501500' THEN 'FP'
END, tb_etiquetas_pecas_d.id
from tb_etiquetas_pecas_d
left join (tb_os left join tbitens on tb_os.produto = tbitens.codigoitem) on (tb_etiquetas_pecas_d.os = tb_os.numero_os)
;



/* View: EVENTOS_CONTABIL */
CREATE VIEW EVENTOS_CONTABIL(
    FILIAL,
    DATA_LANCAMENTO,
    CONTA_DEBITO,
    CONTA_CREDITO,
    VALOR_LANCADO,
    PADRAO_HISTORICO,
    HISTORICO,
    CODFORCLI,
    FORNECEDOR,
    TIPO,
    DATAEMISS,
    DOCTO,
    IDPAGREC,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    CODDESP,
    DESCCONTA,
    SALDO,
    DATAPGTO,
    VALORDOC,
    VALORPGTO,
    FLAG,
    ENTRADA)
AS
select
/*filial*/
'1',
/*data_lancamento*/
PAGREC.datapgto,

/* conta debito */
CASE
WHEN pagrec.tipo = 1 and tb_parametros_eventos.tipo_evento = 1 then tb_parametros_eventos.conta_contabil
when pagrec.tipo = 1 and tb_parametros_eventos.tipo_evento = 0 then
case when contas.regime = 1 then
contas.contacontab
else
tbfor.conta_contabil
end
when pagrec.tipo = 0 and tb_parametros_eventos.tipo_evento = 1 then
case when contas.regime = 1 then
contas.contacontab
else
tbfor.conta_contabil
end
when pagrec.tipo = 0 and tb_parametros_eventos.tipo_evento = 0 then tb_parametros_eventos.conta_contabil 
end,

/*conta credito*/
CASE
WHEN pagrec.tipo = 1 and tb_parametros_eventos.tipo_evento = 1 then
case when contas.regime = 1 then
contas.contacontab 
else
tbfor.conta_contabil
end
when pagrec.tipo = 1 and tb_parametros_eventos.tipo_evento = 0 then tb_parametros_eventos.conta_contabil 
when pagrec.tipo = 0 and tb_parametros_eventos.tipo_evento = 1 then tb_parametros_eventos.conta_contabil 
when pagrec.tipo = 0 and tb_parametros_eventos.tipo_evento = 0 then
case when contas.regime = 1 then
contas.contacontab 
else
tbfor.conta_contabil
end
end,
/* valor lancado*/
F_REPLACE((cast(tb_eventos_fatura.valor_informado as numeric(12,2))),',','.'),
/*historico_padrao*/
5667,
/* historico */
case
when pagrec.tipo = 0 then '"RECTO;'||
tb_parametros_eventos.nome_evento 
||';'||
case when pagrec.pedidos is null then '000000;'
else
f_padleft(f_left(pagrec.pedidos,5),'0',6)
end
||';'||
case when pagrec.docto is null then '000000'
else f_padleft(pagrec.docto,'0',6)
end
||';'||
case
when tbfor.tbforcnpj is null then tbfor.tbforcod 
else tbfor.tbforcnpj 
end
||';'||
case when tbfor.tbforfan is null then ''
else tbfor.tbforfan 
end
||';'||
case when pagrec.naturezadoc is null then ''
else pagrec.naturezadoc 
end
||'"'
when pagrec.tipo = 1 then '"PAGTO;'||
tb_parametros_eventos.nome_evento
||';'||
case when pagrec.pedidos  is null then '000000'
else f_padleft(f_left(pagrec.pedidos,5),'0',6)
end
||';'||
case when pagrec.docto is null then '000000'
else f_padleft(pagrec.docto,'0',6)
end
||';'||
case
when tbfor.tbforcnpj is null then tbfor.tbforcod 
else tbfor.tbforcnpj 
end
||';'||
case when tbfor.tbforfan is null then ''
else tbfor.tbforfan 
end
||';'||
case when pagrec.naturezadoc is null then ''
else pagrec.naturezadoc 
end
||'"'
END,
pagrec.codforcli,
tbfor.tbforraz,
pagrec.tipo,
pagrec.dataemiss,
pagrec.docto,
pagrec.idpagrec,
pagrec.seqdoc,
pagrec.totseqdoc,
pagrec.datavenc,
pagrec.coddesp,
pagrec.descconta,
pagrec.saldo,
pagrec.datapgto,
pagrec.valordoc,
pagrec.valorpgto,
pagrec.flag, pagrec.entrada 
from tb_eventos_fatura
left join (pagrec left join tbbancos on (pagrec.banco = tbbancos.idbanco) left join tbfor on (codforcli = tbfor.tbforcod)
left join contas on (pagrec.coddesp = contas.codconta))
on (id_fatura = pagrec.idpagrec)
LEFT JOIN tb_parametros_eventos ON (tb_eventos_fatura.id_parametro = tb_parametros_eventos.id_evento)
where tb_parametros_eventos.conta_contabil <> '0'

/*where pagrec.datapgto >= '01.10.2008'*/
;



/* View: EXP_CLI */
CREATE VIEW EXP_CLI(
    TBFORCOD,
    TBFORFAN,
    TBFORRAZ,
    TBFORTIPO,
    TBFORCNPJ,
    CLASSIFICACAO,
    TBFORCONT,
    TBFORMAIL,
    CNAE,
    CAE,
    SEXO,
    NASCIMENTO,
    TBFORENDER,
    NM,
    TBFORBAIRRO,
    TBFORCID,
    TBFOREST,
    CODMUN,
    TBFORCEP,
    DDD,
    TBFORFONE,
    TBFORFAX,
    CAIXA,
    MAIL,
    SITE,
    CEPCP,
    DDD2,
    FONE2,
    TBFORINSCEST,
    TBFORINSCMUN)
AS
select 
'"C' || tbforcod || '"', '"' || tbforfan || '"','"' || tbforraz || '"','"' || f_left(tbfortipo,1) ||'"','"' || tbforcnpj || '"',
'""' as classificacao,'"' || tbforcont || '"','"' || tbformail ||'"', '""' as cnae,'""' as cae,'""' as sexo,'""' as nascimento,'"' ||tbforender||'"','""' as nm,'"' ||tbforbairro||'"',
'"' ||tbforcid||'"','"' || tbforest||'"','""' as codmun,'"' ||tbforcep||'"','""' as ddd,'"' || f_right(tbforfone,10)||'"','"' ||f_right(tbforfax,10) ||'"','""' as caixa,'""' as mail,'""' as site,'""' as cepcp,'""' as ddd2,'""' as fone2,
'"' ||tbforinscest||'"','"' ||tbforinscmun||'"'
from tbfor where tbfor.tbforclifor >=1 and f_stringlength(tbforcnpj)=18
;



/* View: EXPORTA */
CREATE VIEW EXPORTA(
    CODIGOITEM,
    NOMEITEM,
    DESENHOITEM)
AS
select codigoitem, nomeitem, desenhoitem from tbitens
;



/* View: EXPORTA_CONTABIL */
CREATE VIEW EXPORTA_CONTABIL(
    FILIAL,
    DATA_LANCAMENTO,
    CONTA_DEBITO,
    CONTA_CREDITO,
    VALOR_LANCADO,
    PADRAO_HISTORICO,
    HISTORICO,
    CODFORCLI,
    FORNECEDOR,
    TIPO,
    DATAEMISS,
    DOCTO,
    IDPAGREC,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    CODDESP,
    DESCCONTA,
    SALDO,
    DATAPGTO,
    VALORDOC,
    VALORPGTO,
    FLAG,
    IDBANCO,
    CTBANCO,
    CTCONTA,
    CODDESP_FOR,
    NOME_FOR,
    C_CRED,
    C_DEB,
    ENTRADA)
AS
select
'1',
pagrec.datapgto,

/* conta debito */
case when pagrec.tipo = 0 then
tbbancos.conta_contabil
when pagrec.tipo = 1 then
contas.contacontab
end,
/* conta credito */
case when pagrec.tipo = 0 then
contas.contacontab
when pagrec.tipo = 1 then
tbbancos.conta_contabil
end,
case
when pagrec.valorpgto = 0 then
f_replace(pagrec.valordoc,',','.')
else
f_replace(pagrec.valorpgto,',','.')
end,
5667,
case
when pagrec.tipo = 0 then '"RECTO;;'||
case when pagrec.pedidos is null then '000000;'
else
f_padleft(f_left(pagrec.pedidos,5),'0',6)
end
||';'||
case when pagrec.docto is null then '000000'
else f_padleft(pagrec.docto,'0',6)
end
||';'||
case
when tbfor.tbforcnpj is null then tbfor.tbforcod 
else tbfor.tbforcnpj 
end
||';'||
case when tbfor.tbforfan is null then ''
else tbfor.tbforfan 
end
||';'||
case when pagrec.naturezadoc is null then ''
else pagrec.naturezadoc 
end
||'"'
when pagrec.tipo = 1 then '"PAGTO;;'||
case when pagrec.pedidos  is null then '000000'
else f_padleft(f_left(pagrec.pedidos,5),'0',6)
end
||';'||

case when pagrec.docto is null then '000000'
else f_padleft(pagrec.docto,'0',6)
end
||';'||
case
when tbfor.tbforcnpj is null then tbfor.tbforcod 
else tbfor.tbforcnpj 
end
||';'||
case when tbfor.tbforfan is null then ''
else tbfor.tbforfan 
end
||';'||
case when pagrec.naturezadoc is null then ''
else pagrec.naturezadoc 
end
||'"'
END
,
pagrec.codforcli,
pagrec.descr,
pagrec.tipo,
DATAEMISS, docto, idpagrec, seqdoc, totseqdoc, datavenc, coddesp, descconta, saldo, datapgto, pagrec.valordoc, pagrec.valorpgto, flag,
tbbancos.idbanco , tbbancos.conta_contabil, contas.contacontab,
tbfor.codigo_financeiro, tbfor.tbforfan, pagrec.ccred , pagrec.cdeb, pagrec.entrada 
from pagrec left join contas on (pagrec.coddesp = contas.codconta)
left join tbfor on (pagrec.codforcli = tbfor.tbforcod)
left join tbbancos on (pagrec.banco = tbbancos.idbanco)
/* where pagrec.datapgto >= '01.10.2008' and pagrec.valorpgto > 0 and pagrec.coddesp <> '001.020' */
where pagrec.valorpgto > 0 and pagrec.coddesp <> '001.020'
;



/* View: EXPORTA_CONTABILIDADE */
CREATE VIEW EXPORTA_CONTABILIDADE(
    FILIAL,
    DATA_LANCAMENTO,
    CONTA_DEBITO,
    CONTA_CREDITO,
    VALOR_LANCADO,
    PADRAO_HISTORICO,
    HISTORICO,
    CODFORCLI,
    FORNECEDOR,
    TIPO,
    DATAEMISS,
    DOCTO,
    IDPAGREC,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    CODDESP,
    DESCCONTA,
    SALDO,
    DATAPGTO,
    VALORDOC,
    VALORPGTO,
    FLAG,
    ENTRADA)
AS
select filial, data_lancamento, conta_debito, conta_credito, valor_lancado, padrao_historico, historico, codforcli, fornecedor, tipo, dataemiss, docto, idpagrec, seqdoc, totseqdoc, datavenc, coddesp, descconta, saldo, datapgto, valordoc, valorpgto, flag, entrada
from exporta_contabil union all
select filial, data_lancamento, conta_debito, conta_credito, valor_lancado, padrao_historico, historico, codforcli, fornecedor, tipo, dataemiss, docto, idpagrec, seqdoc, totseqdoc, datavenc, coddesp, descconta, saldo, datapgto, valordoc, valorpgto, flag, entrada
from eventos_contabil
;



/* View: FLUXO_PROCESSO */
CREATE VIEW FLUXO_PROCESSO(
    IDARVPROC,
    IDARVMAT,
    ARVORE,
    PRODUTO,
    CODIGOITEM,
    COMPONENTE,
    SEQ,
    CALCULO,
    OBS,
    MNUM,
    QTDEOPER,
    SETOR,
    IDREC1,
    IDREC2,
    IDREC3,
    IDREC4,
    IDREC5,
    QTDESETUP,
    TEMPOPECA,
    SETPECA,
    TREAL,
    UNDOPER,
    MO,
    DESCROPER,
    VROPER,
    PCHORA,
    CODIGOPAI,
    PROXIMO,
    ANTERIOR,
    PIERCE,
    ROTEIRO,
    MINIMO,
    MAXIMO,
    ALTERACAO,
    USUARIO,
    ULTIMOCAMPO,
    PESOLIQ,
    VR_MAQ,
    VR_MO,
    VR_APOIO,
    TIPOSETOR,
    PPART,
    CUSTO,
    TIPO,
    GERA_FMEA,
    CE,
    NOMESETOR,
    NCC,
    NOMEITEM,
    TXHORA)
AS
select a.idarvproc, a.idarvmat, a.arvore, a.produto, a.codigoitem, a.componente, a.seq, a.calculo, a.obs, a.mnum, a.qtdeoper, a.setor, a.idrec1, a.idrec2, a.idrec3, a.idrec4, a.idrec5, a.qtdesetup, a.tempopeca, a.setpeca, a.treal, a.undoper, a.mo, a.descroper, a.vroper, a.pchora, a.codigopai, a.proximo, a.anterior, a.pierce, a.roteiro, a.minimo, a.maximo, a.alteracao, a.usuario, a.ultimocampo, tbitens.pesoliqitem, a.vr_maq, a.vr_mo, a.vr_apoio, tiposetor,a.ppart,
custo, tb_atividade.tiPO, tb_tipo_atividade.gera_fmea, caracteres_especiais.ce, tbsetor.nomesetor, tbsetor.ncc, tbitens.nomeitem, tbsetor.custohora+tbsetor.customo+tbsetor.custoapoio from tbarvoreproc a left join (tb_atividade LEFT JOIN tb_tipo_atividade ON (tb_atividade.tipo = tb_tipo_atividade.id))
on (a.mnum = tb_atividade.id) left join tbsetor on (a.setor = tbsetor.idsetor)
left join tbitens on (a.produto = tbitens.codigoitem)
left join caracteres_especiais on (a.roteiro = caracteres_especiais.idfmea)
;



/* View: EXPORTA_EGA */
CREATE VIEW EXPORTA_EGA(
    CODIGO,
    DESCRICAO,
    COD_OPERACAO,
    NUM_OPERACAO,
    OPERACAO,
    PCS_CICLO,
    PCS_HORA,
    TIPO,
    CUSTO)
AS
select f_replace(f_replace(fluxo_processo.produto,'.',''),'-',''), tbitens.nomeitem, fluxo_processo.mnum, fluxo_processo.descroper,   fluxo_processo.seq, fluxo_processo.undoper, fluxo_processo.pchora, tipo, custo from
fluxo_processo left join tbitens on (produto = tbitens.codigoitem)
order by fluxo_processo.produto, fluxo_processo.seq
;



/* View: EXPORTA_NF2PCP */
CREATE VIEW EXPORTA_NF2PCP(
    CAPNF,
    CAPCLI,
    CAPDEMI,
    CAPEMIT,
    CAPFLACLI,
    CAPFLANF,
    CAPFLAEM,
    CAPFLATE,
    CAPFLAI,
    CAPIPRO1,
    CAPILOT11,
    CAPILOT12,
    CAPILOT13,
    CAPLIOT14,
    CAPIQTD11,
    CAPIQTD12,
    CAPIQTD13,
    CAPIQTD14,
    CAPIVAL1,
    CAPIPOR1,
    STASUFRAMA)
AS
select numnf, codcli, emissao, 'N',
case stacom
when 0 then 'C'
when 2 then 'F'
end, '*', '',
case stacom
when 0 then 'V'
when 2 then 'R'
end, '',  codigoitem, n_os, n_os2, n_os3, n_os4,
qt_os, qt_os2, qt_os3, qt_os4, vlunit, fconv, stasuframa from
tbnf join tbitensnf on (numnf = idnumnf) where stasuframa = 0 and stacom in(0,2) and emissao is not null
;



/* View: EXPORTA_NOTANET */
CREATE VIEW EXPORTA_NOTANET(
    CNPJ,
    RAZAO,
    FANTASIA,
    EMAIL_CONTATO,
    FONE,
    ENDERECO,
    COMPLEMENTO,
    END_NUMERO,
    BAIRRO,
    CEP,
    MUNICIPIO,
    UF,
    INSC_ESTADUAL,
    SUFRAMA,
    EMAIL_NFE_AUTORIZADA,
    EMAIL_CANCELA_NFE)
AS
select
f_replace(f_replace(f_replace(tbfor.tbforcnpj,'.',''),'-',''),'/',''),
tbfor.tbforraz, tbfor.tbforfan, tbfor.tbformail,
f_replace(f_replace(f_replace(tbfor.tbforfone,')',''),'(',''),'-',''),
tbfor.tbforender, tbfor.complemento, tbfor.endereco_numero,
tbfor.tbforbairro,
f_replace(f_replace(tbfor.tbforcep,'.',''),'-',''),
tbfor.tbforcid,
tbfor.tbforest,
f_replace(tbfor.tbforinscest,'.',''),
'', tbfor.tbformail, tbfor.tbformail 
from tbfor
;



/* View: V_TERC */
CREATE VIEW V_TERC(
    CODFOR,
    NOTA_SAIDA,
    OS,
    CODIGOMAT,
    SALDO,
    QTD_SALDO)
AS
select c.codfor, c.nota_saida, c.os,  c.codigomat,
c.saldo, (select min(saldo) from tb_terceiro n
where n.codfor = c.codfor and n.nota_saida = c.nota_saida and n.codigomat = c.codigomat 
) as qtd_saldo from tb_terceiro c order by c.codfor, c.nota_saida,
c.codigomat , c.idlanc
;



/* View: GROUP_TERC */
CREATE VIEW GROUP_TERC(
    CODFOR,
    NOTA_SAIDA,
    OS,
    CODIGOMAT,
    QTD_SALDO)
AS
select codfor, nota_saida, os, codigomat, qtd_saldo
from v_terc group by codfor, nota_saida, os, codigomat, qtd_saldo
having (os <> 0)
;



/* View: FASE_TERCEIRO */
CREATE VIEW FASE_TERCEIRO(
    OS,
    CODIGOMAT,
    QTD_SALDO,
    PRODUTO,
    SEQ,
    DESCROPER,
    TIPOSETOR,
    TIPO)
AS
select os, codigomat, qtd_saldo, produto, seq, descroper, tiposetor, tipo
from group_terc left join fluxo_processo on (group_terc.codigomat = fluxo_processo.produto)
where fluxo_processo.tipo = 9
;



/* View: FAT_CLIENTES_ANO */
CREATE VIEW FAT_CLIENTES_ANO(
    ANO,
    CODCLI,
    FANTASIA,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF)
AS
select ANO, codcli, fantasia, cast(SUM(valoricms) as numeric(14,2)), cast(SUM(valoripi) as numeric(14,2)), cast(SUM(valoritens) as numeric(14,2)), cast(SUM(valortotalnf) as numeric(14,2)) from nf_fat_prod
GROUP BY ANO, codcli, fantasia order by ANO, CODCLI
;



/* View: FAT_CLIENTES_DIA */
CREATE VIEW FAT_CLIENTES_DIA(
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    FANTASIA,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF)
AS
select dia, dia_sem, mes_ano, codcli, fantasia, cast(SUM(valoricms) as numeric(14,2)), cast(SUM(valoripi) as numeric(14,2)), cast(SUM(valoritens) as numeric(14,2)), cast(SUM(valortotalnf) as numeric(14,2)) from nf_fat_prod
GROUP BY dia, dia_sem, mes_ano, codcli, fantasia order by codcli, dia
;



/* View: NF_FAT_FER */
CREATE VIEW NF_FAT_FER(
    NUMNF,
    SISTEMA,
    EMISSAO,
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    CFOP,
    NFCFOPI,
    DESCCFOP,
    VALORICMS,
    VALORIPI,
    VALORITENS,
    VALORTOTALNF,
    UNIDADE)
AS
select
numnf, sistema, emissao, f_dayofmonth(emissao), f_cdowSHORTlang(emissao,'PT') , f_padleft(f_month(emissao),'0',2) || '/' || f_year(EMISSAO) , codcli, razao, fantasia, tipo, canc, vend, nomevend, stacom, tbnf.status,
cfop,nfcfopi, desccfop, valoricms, valoripi, valoritens, valortotalnf, tbnf.unidade
from tbnf WHERE (STACOM = 3) and (canc = 'N') and (tipo = 'S')
;



/* View: FAT_FER_DIA */
CREATE VIEW FAT_FER_DIA(
    MES_ANO,
    CODCLI,
    FANTASIA,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF)
AS
select mes_ano, codcli, fantasia, SUM(valoricms), SUM(valoripi), SUM(valoritens), SUM(valortotalnf) from nf_fat_fer
GROUP BY mes_ano, codcli, fantasia order by codcli, MES_ANO
;



/* View: NF_DEV_PROD_FAT */
CREATE VIEW NF_DEV_PROD_FAT(
    NUMNF,
    SISTEMA,
    EMISSAO,
    ANO,
    MES,
    MESNUM,
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    CFOP,
    NFCFOPI,
    DESCCFOP,
    VALORICMS,
    VALORIPI,
    VALORITENS,
    VALORTOTALNF,
    UNIDADE)
AS
select
numnf, sistema, emissao,f_year(emissao), f_cmonthshortlang(emissao,'PT'), f_month(emissao),  f_dayofmonth(emissao), f_cdowSHORTlang(emissao,'PT') , f_padleft(f_month(emissao),'0',2) || '/' || f_year(EMISSAO) , codcli, razao, fantasia, tipo, canc, vend, nomevend, stacom, tbnf.status,
cfop,nfcfopi, desccfop, valoricms, valoripi, valoritens, valortotalnf, unidade
from tbnf WHERE (cfop in('1.201','2.201','3.201')) and (tipo = 'E')
;



/* View: FAT_REC_DIA */
CREATE VIEW FAT_REC_DIA(
    MES_ANO,
    CODCLI,
    FANTASIA,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF,
    MES,
    ANO,
    MESNUM)
AS
select mes_ano, codcli, fantasia, SUM(valoricms), SUM(valoripi), SUM(valoritens), SUM(valortotalnf), mes, ano, mesnum from nf_dev_prod_fat
GROUP BY mes_ano, codcli, fantasia, mes, ano, mesnum order by codcli, MES_ANO
;



/* View: NF_FAT_SUC */
CREATE VIEW NF_FAT_SUC(
    NUMNF,
    SISTEMA,
    EMISSAO,
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    CFOP,
    NFCFOPI,
    DESCCFOP,
    VALORICMS,
    VALORIPI,
    VALORITENS,
    VALORTOTALNF,
    UNIDADE)
AS
select
numnf, sistema, emissao, f_dayofmonth(emissao), f_cdowSHORTlang(emissao,'PT') , f_padleft(f_month(emissao),'0',2) || '/' || f_year(EMISSAO) , codcli, razao, fantasia, tipo, canc, vend, nomevend, stacom, tbnf.status,
cfop,nfcfopi, desccfop, valoricms, valoripi, valoritens, valortotalnf, tbnf.unidade
from tbnf WHERE (STACOM = 2) and (canc = 'N') and (tipo = 'S')
;



/* View: FAT_SUC_DIA */
CREATE VIEW FAT_SUC_DIA(
    MES_ANO,
    CODCLI,
    FANTASIA,
    VR_ICMS,
    VR_IPI,
    VR_ITENS,
    VR_NF)
AS
select mes_ano, codcli, fantasia, SUM(valoricms), SUM(valoripi), SUM(valoritens), SUM(valortotalnf) from nf_fat_SUC
GROUP BY mes_ano, codcli, fantasia order by codcli, MES_ANO
;



/* View: FATURAMENTO_MENSAL */
CREATE VIEW FATURAMENTO_MENSAL(
    ID,
    USUARIO,
    CODCLI,
    NOME,
    MESBASE,
    D01,
    D02,
    D03,
    D04,
    D05,
    D06,
    D07,
    D08,
    D09,
    D10,
    D11,
    D12,
    D13,
    D14,
    D15,
    D16,
    D17,
    D18,
    D19,
    D20,
    D21,
    D22,
    D23,
    D24,
    D25,
    D26,
    D27,
    D28,
    D29,
    D30,
    D31,
    TOTAL_CLI,
    TOTAL_DEV,
    TOTAL_PREV,
    TOTAL_REC,
    TOTAL_FER,
    SALDO_TOT,
    DS01,
    DS02,
    DS03,
    DS04,
    DS05,
    DS06,
    DS07,
    DS08,
    DS09,
    DS10,
    DS11,
    DS12,
    DS13,
    DS14,
    DS15,
    DS16,
    DS17,
    DS18,
    DS19,
    DS20,
    DS21,
    DS22,
    DS23,
    DS24,
    DS25,
    DS26,
    DS27,
    DS28,
    DS29,
    DS30,
    DS31,
    D01_S_IMP,
    D01_C_ICM,
    D01_BRUTO,
    D02_S_IMP,
    D02_C_ICM,
    D02_BRUTO,
    D03_S_IMP,
    D03_C_ICM,
    D03_BRUTO,
    D04_S_IMP,
    D04_C_ICM,
    D04_BRUTO,
    D05_S_IMP,
    D05_C_ICM,
    D05_BRUTO,
    D06_S_IMP,
    D06_C_ICM,
    D06_BRUTO,
    D07_S_IMP,
    D07_C_ICM,
    D07_BRUTO,
    D08_S_IMP,
    D08_C_ICM,
    D08_BRUTO,
    D09_S_IMP,
    D09_C_ICM,
    D09_BRUTO,
    D10_S_IMP,
    D10_C_ICM,
    D10_BRUTO,
    D11_S_IMP,
    D11_C_ICM,
    D11_BRUTO,
    D12_S_IMP,
    D12_C_ICM,
    D12_BRUTO,
    D13_S_IMP,
    D13_C_ICM,
    D13_BRUTO,
    D14_S_IMP,
    D14_C_ICM,
    D14_BRUTO,
    D15_S_IMP,
    D15_C_ICM,
    D15_BRUTO,
    D16_S_IMP,
    D16_C_ICM,
    D16_BRUTO,
    D17_S_IMP,
    D17_C_ICM,
    D17_BRUTO,
    D18_S_IMP,
    D18_C_ICM,
    D18_BRUTO,
    D19_S_IMP,
    D19_C_ICM,
    D19_BRUTO,
    D20_S_IMP,
    D20_C_ICM,
    D20_BRUTO,
    D21_S_IMP,
    D21_C_ICM,
    D21_BRUTO,
    D22_S_IMP,
    D22_C_ICM,
    D22_BRUTO,
    D23_S_IMP,
    D23_C_ICM,
    D23_BRUTO,
    D24_S_IMP,
    D24_C_ICM,
    D24_BRUTO,
    D25_S_IMP,
    D25_C_ICM,
    D25_BRUTO,
    D26_S_IMP,
    D26_C_ICM,
    D26_BRUTO,
    D27_S_IMP,
    D27_C_ICM,
    D27_BRUTO,
    D28_S_IMP,
    D28_C_ICM,
    D28_BRUTO,
    D29_S_IMP,
    D29_C_ICM,
    D29_BRUTO,
    D30_S_IMP,
    D30_C_ICM,
    D30_BRUTO,
    D31_S_IMP,
    D31_C_ICM,
    D31_BRUTO)
AS
select id, usuario, tb_fat.codcli, nome, tb_fat.mesbase, d01, d02, d03, d04, d05, d06, d07, d08, d09, d10, d11, d12, d13, d14, d15,
 d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31, total_cli, total_dev, total_prev,
 total_rec, total_fer, saldo_tot, ds01, ds02, ds03, ds04, ds05, ds06, ds07, ds08, ds09, ds10, ds11, ds12, ds13,
 ds14, ds15, ds16, ds17, ds18, ds19, ds20, ds21, ds22, ds23, ds24, ds25, ds26, ds27, ds28, ds29, ds30, ds31,
 d01_s_imp, d01_c_icm, d01_bruto, d02_s_imp, d02_c_icm, d02_bruto, d03_s_imp, d03_c_icm, d03_bruto, d04_s_imp,
 d04_c_icm, d04_bruto, d05_s_imp, d05_c_icm, d05_bruto, d06_s_imp, d06_c_icm, d06_bruto, d07_s_imp, d07_c_icm,
 d07_bruto, d08_s_imp, d08_c_icm, d08_bruto, d09_s_imp, d09_c_icm, d09_bruto, d10_s_imp, d10_c_icm, d10_bruto,
 d11_s_imp, d11_c_icm, d11_bruto, d12_s_imp, d12_c_icm, d12_bruto, d13_s_imp, d13_c_icm, d13_bruto, d14_s_imp,
 d14_c_icm, d14_bruto, d15_s_imp, d15_c_icm, d15_bruto, d16_s_imp, d16_c_icm, d16_bruto, d17_s_imp, d17_c_icm,
 d17_bruto, d18_s_imp, d18_c_icm, d18_bruto, d19_s_imp, d19_c_icm, d19_bruto, d20_s_imp, d20_c_icm, d20_bruto,
 d21_s_imp, d21_c_icm, d21_bruto, d22_s_imp, d22_c_icm, d22_bruto, d23_s_imp, d23_c_icm, d23_bruto, d24_s_imp,
 d24_c_icm, d24_bruto, d25_s_imp, d25_c_icm, d25_bruto, d26_s_imp, d26_c_icm, d26_bruto, d27_s_imp, d27_c_icm,
 d27_bruto, d28_s_imp, d28_c_icm, d28_bruto, d29_s_imp, d29_c_icm, d29_bruto, d30_s_imp, d30_c_icm, d30_bruto,
 d31_s_imp, d31_c_icm, d31_bruto
 from tb_fat left join tb_prev on (tb_fat.codcli = tb_prev.codcli and tb_fat.mesbase = tb_prev.base)
 where tb_fat.mesbase = '02/2009' and USUARIO = 'PEDRO' ORDER BY
 total_cli desc
;



/* View: FATURAS */
CREATE VIEW FATURAS(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    ESTAGIO,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    HIST,
    VALORDOC,
    NATUREZADOC,
    CODDESP,
    DATAPGTO,
    VALORPGTO,
    MESBASE,
    MESCOMP,
    CARTEIRA,
    BANCO,
    IDMOV,
    STATUS,
    ULTREV,
    ALTPOR,
    GERADO,
    FORMPAG,
    REG,
    FLAG,
    SALDO,
    NOMECONTA,
    EXTENSO,
    PEDIDOS,
    NOMEBANCO,
    ENTRADA,
    RECEBER,
    PAGAR,
    PAGO,
    PENDENTE)
AS
select idpagrec, dataemiss, tbfor.tbforraz , tipo, codforcli, estagio, docto, seqdoc, totseqdoc,

case when cartorio
is not null then cartorio
else
datavenc
end , hist,
valordoc , naturezadoc, coddesp, datapgto,
valorpgto, mesbase, mescomp, carteira, banco, idmov, status, pagrec.ultrev, altpor, gerado, formpag, reg, flag,

saldo,pagrec.descconta, extenso, pedidos, tbbancos.nomebanco, pagrec.entrada,
CASE WHEN TIPO = 0 THEN valordoc
WHEN TIPO = 2 THEN valordoc
else
0
END,
CASE WHEN TIPO = 1 THEN valordoc * -1
WHEN TIPO = 3 THEN valordoc * -1
else
0
END,
CASE WHEN TIPO = 1 THEN valorpgto * -1
WHEN TIPO = 0 THEN valorpgto
WHEN TIPO = 2 THEN valorpgto
WHEN TIPO = 3 THEN valorpgto * -1
else
0
END,
CASE WHEN TIPO = 1 THEN saldo * -1
WHEN TIPO = 0 THEN saldo
WHEN TIPO = 2 THEN saldo
WHEN TIPO = 3 THEN saldo * -1
else
0
END


from pagrec left join tbbancos on (pagrec.banco = tbbancos.idbanco)
left join tbfor on (pagrec.codforcli = tbfor.tbforcod)
;



/* View: FATURAS_2008 */
CREATE VIEW FATURAS_2008(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    HIST,
    VALORDOC,
    VALORJUROS,
    VALORDESCONTO,
    NATUREZADOC,
    CODDESP,
    DATAPGTO,
    VALORPGTO,
    MESBASE,
    MESCOMP,
    CARTEIRA,
    BANCO,
    FORMPAG,
    SALDO,
    NOMECONTA,
    NOMEBANCO)
AS
select idpagrec, dataemiss, descr, tipo, codforcli, docto, seqdoc, totseqdoc, datavenc, hist, valordoc,pagrec.valjuro, pagrec.valdesc,   naturezadoc, coddesp, datapgto, valorpgto, mesbase, mescomp,  carteira, banco, formpag, saldo,pagrec.descconta, tbbancos.nomebanco
from pagrec left join tbbancos on (pagrec.banco = tbbancos.idbanco)
WHERE TIPO = 1 AND pagrec.datapgto >= '01.01.2008'
;



/* View: FATURAS_ABERTAS_31_AGOSTO_2008 */
CREATE VIEW FATURAS_ABERTAS_31_AGOSTO_2008(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    HIST,
    VALORDOC,
    VALORJUROS,
    VALORDESCONTO,
    NATUREZADOC,
    CODDESP,
    DATAPGTO,
    VALORPGTO,
    MESBASE,
    MESCOMP,
    CARTEIRA,
    BANCO,
    FORMPAG,
    SALDO,
    NOMECONTA,
    NOMEBANCO)
AS
select idpagrec, dataemiss, descr, tipo, codforcli, docto, seqdoc, totseqdoc, datavenc, hist, valordoc,pagrec.valjuro, pagrec.valdesc,   naturezadoc, coddesp, datapgto, valorpgto, mesbase, mescomp,  carteira, banco, formpag, saldo,pagrec.descconta, tbbancos.nomebanco
from pagrec left join tbbancos on (pagrec.banco = tbbancos.idbanco)
WHERE TIPO = 1 AND pagrec.dataemiss between '01.01.2007' and '31.08.2008' and (saldo > 0 or (pagrec.datapgto > '31.08.2008'))
;



/* View: FATURAS_ERRO */
CREATE VIEW FATURAS_ERRO(
    NUMNF,
    EMISSAO,
    CODCLI,
    FANTASIA,
    CFOP,
    DESCCFOP,
    VALORTOTALNF,
    NOSSOPED)
AS
select
numnf, emissao, codcli, fantasia, cfop, desccfop, valortotalnf, nossoped
from tbnf
where cfop like '5.920'
;



/* View: FATURAS_EVENTOS */
CREATE VIEW FATURAS_EVENTOS(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    VALORDOC,
    NATUREZADOC,
    CODDESP,
    DATAPGTO,
    VALORPGTO,
    MESBASE,
    MESCOMP,
    CARTEIRA,
    BANCO,
    IDMOV,
    FORMPAG,
    REG,
    SALDO,
    DESCCONTA,
    PEDIDOS,
    SUBCFOP,
    CCRED,
    CDEB,
    ID_EVENTO,
    ID_FATURA,
    ID_PARAMETRO,
    VALOR_INFORMADO,
    NOME_EVENTO,
    TIPO_EVENTO,
    CONTA_CONTABIL,
    ESTAGIO,
    STATUS,
    FLAG,
    CARTORIO)
AS
select idpagrec, dataemiss, descr, tipo, codforcli, docto, seqdoc, totseqdoc, datavenc, valordoc, naturezadoc, coddesp, datapgto, valorpgto, mesbase, mescomp, carteira, banco, idmov, formpag, reg, saldo, descconta, pedidos, subcfop, ccred, cdeb,
tb_eventos_fatura.id_evento , id_fatura, id_parametro, valor_informado, tb_eventos_fatura.nome_evento,
tipo_evento, conta_contabil, PAGREC.estagio, PAGREC.status, PAGREC.FLAG, PAGREC.cartorio
from pagrec left join tb_eventos_fatura left join tb_parametros_eventos on (tb_eventos_fatura.id_parametro = tb_parametros_eventos.id_evento)  on (pagrec.idpagrec = tb_eventos_fatura.id_fatura) where pagrec.dataemiss >= '01.10.2008'
;



/* View: FLUXO_FATURA */
CREATE VIEW FLUXO_FATURA(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    ESTAGIO,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    HIST,
    VALORDOC,
    NATUREZADOC,
    CODDESP,
    DATAPGTO,
    VALORPGTO,
    MESBASE,
    MESCOMP,
    PORCJUROS,
    PORCIR,
    PORCINSS,
    PORCDESC,
    VALJURO,
    VALIR,
    VALINSS,
    VALDESC,
    CARTEIRA,
    BANCO,
    IDMOV,
    STATUS,
    ULTREV,
    ALTPOR,
    GERADO,
    FORMPAG,
    REG,
    FLAG,
    SALDO,
    DESCCONTA,
    IDCPAGPED,
    EXTENSO,
    PEDIDOS,
    PORPISCOFINS,
    VALPISCOFINS,
    SUBCFOP,
    CCRED,
    CDEB,
    INCLUI_FLUXO)
AS
select
 idpagrec, dataemiss, descr, tipo, codforcli, estagio, docto, seqdoc,
 totseqdoc, datavenc, hist, valordoc, naturezadoc, coddesp, datapgto,
 valorpgto, mesbase, mescomp, porcjuros, porcir, porcinss, porcdesc,
 valjuro, valir, valinss, valdesc, carteira, banco, idmov, status,
 ultrev, altpor, gerado, formpag, reg, flag, saldo, descconta,
 idcpagped, extenso, pedidos, porpiscofins, valpiscofins,
 subcfop, ccred, cdeb, contas.inclui_fluxo 
from pagrec left join contas on (pagrec.coddesp = contas.codconta)
where contas.inclui_fluxo <> 1
;



/* View: FLUXO_REALIZADO */
CREATE VIEW FLUXO_REALIZADO(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    HIST,
    VALORDOC,
    CODDESP,
    DESCCONTA,
    DATAPGTO,
    VALOR_PAGO,
    VALOR_RECEBIDO,
    PEDIDOS,
    SUBCFOP,
    CCRED,
    CDEB,
    ENTRADA,
    PROJETO)
AS
select idpagrec, dataemiss, descr, tipo, codforcli, docto, seqdoc, totseqdoc, datavenc, hist, valordoc, coddesp,descconta, datapgto,
case tipo
when 1 then valorpgto
else 0
end,
case tipo
when 0 then valorpgto
else 0
end,
pedidos, subcfop, ccred, cdeb, PAGREC.entrada, TBPROPC.formaenv
from pagrec left JOIN tbpropc ON (PAGREC.pedidos = tbpropc.numped) where pagrec.datavenc between '01.10.2008' and '31.12.2012'
and tipo in(1) AND f_stringlength4(pagrec.pedidos) = 5 and tbpropc.formaenv = 'AN'
;



/* View: GRADE_INSPECAO */
CREATE VIEW GRADE_INSPECAO(
    DATA_INSPECAO,
    CODIGO,
    OPERACAO,
    INSPECAO,
    APROVADO,
    REPROVADO,
    CONCESSAO,
    RETRABALHO,
    SELECAO,
    SUCATA)
AS
select A.data_inspecao, a.codigo, a.operacao,
case when a.disposicao = 'INSPE��O' THEN a.qtde else 0 end,
case when a.disposicao = 'APROVADO' THEN a.qtde else 0 end,
case when a.disposicao = 'REPROVADO' THEN a.qtde else 0 end,
case when a.disposicao = 'CONCESS�O' THEN a.qtde else 0 end,
case when a.disposicao = 'RETRABALHO' THEN a.qtde else 0 end,
case when a.disposicao = 'SELE��O' THEN a.qtde else 0 end,
case when a.disposicao = 'SUCATA' THEN a.qtde else 0 end
from APONTAMENTOS_VALOR a where a.disposicao in ('INSPE��O','APROVADO','CONCESS�O','REPROVADO','RETRABALHO','SELE��O','SUCATA')
order BY a.data_inspecao, a.codigo, a.operacao
;



/* View: GRUPO_MOV */
CREATE VIEW GRUPO_MOV(
    IDMOV,
    CODCLI,
    NOMECLI,
    TOTAL)
AS
select pagrec.idmov, pagrec.codforcli,   pagrec.descr, count(pagrec.idmov) from pagrec
group by pagrec.idmov, pagrec.codforcli,   pagrec.descr having (idmov <> 0) order by idmov
;



/* View: GRUPO_NOTA */
CREATE VIEW GRUPO_NOTA(
    CODCLI,
    CFOP,
    PEDIDOCLI)
AS
select codcli, cfop, pedidocli from tbnfc
;



/* View: GRUPOS_CC */
CREATE VIEW GRUPOS_CC(
    IDCC,
    NCC,
    TIPO,
    GRUPO)
AS
select CCUSTO.idccusto, TBSETOR.ncc, CCUSTO.tipomo,
CASE ccusto.tipomo
WHEN 'MOD' THEN '34'
when 'MOIA' THEN '45'
WHEN 'MOIP' THEN '35'
WHEN 'MOIC' THEN '55'
END
from ccusto LEFT JOIN TBSETOR ON (CCUSTO.idccusto = TBSETOR.idccusto)
where f_stringlength(tbsetor.ncc) >= 5
group by
CCUSTO.idccusto, TBSETOR.ncc, CCUSTO.tipomo,
CASE ccusto.tipomo
WHEN 'MOD' THEN '34'
when 'MOIA' THEN '45'
WHEN 'MOIP' THEN '35'
WHEN 'MOIC' THEN '55'
END
;



/* View: GRUPOS_CC_TOT */
CREATE VIEW GRUPOS_CC_TOT(
    IDCC,
    NOMECC,
    TIPO,
    GRUPO)
AS
select CCUSTO.idccusto, ccusto.nome, CCUSTO.tipomo,
CASE ccusto.tipomo
WHEN 'MOD' THEN '34'
when 'MOIA' THEN '45'
WHEN 'MOIP' THEN '35'
WHEN 'MOIC' THEN '55'
END
from ccusto where f_stringlength(ccusto.idccusto) >= 5
;



/* View: GRUPOS_CC_ALL */
CREATE VIEW GRUPOS_CC_ALL(
    NCC,
    GRUPO)
AS
select grupos_cc_tot.idcc, grupos_cc_tot.grupo from grupos_cc_tot
union all
select grupos_cc.ncc,  grupos_cc.grupo from grupos_cc
;



/* View: HEADER_ASN */
CREATE VIEW HEADER_ASN(
    CNPJTRANSMISSOR,
    CNPJRECEPTOR,
    CODIGOFORNECEDOR,
    NOMETRANSMISSOR,
    NOMERECEPTOR,
    NOTAFISCAL,
    SERIE,
    EMISSAO,
    VALORTOTALNOTA,
    CFOP,
    VALORTOTALICMS,
    VENCIMENTOFATURA,
    VALORTOTALIPI,
    CODIGOFABRICA,
    VALORDESPACESSORIAS,
    VALORFRETE,
    VALORSEGURO,
    VALORDESCONTO,
    BASEICMS,
    DESCONTOICMS)
AS
select d.cnpj, a.cnpjcli, b.tbforcodant, d.fantasia, a.razao, a.nf_numero, '1', a.emissao,
a.valortotalnf, a.cfop, a.valoricms, c.datavenc, a.valoripi, f_right(b.tbforcheck1,3), a.outrasdepesas, a.valorfrete,
a.valorseguro, '000000000000', a.baseicms, '000000000000'
  from tbnf a left join tbfor b on (a.codcli = b.tbforcod)
left join tbempresa d on (a.unidade = d.id)
left join pagrec c on (cast(a.nf_numero as varchar(50))= c.docto
and a.codcli = c.codforcli and a.emissao = c.dataemiss)
where b.tbforflag2 >= '1'
;



/* View: RCQ */
CREATE VIEW RCQ(
    RC,
    COD,
    TBRCQRC,
    TBRCQRCREV,
    TBRCQTIPO,
    TBRCQSETOR,
    TBRCQOBS,
    TBRCQESPCOM,
    TBRCQELAB,
    TBRCQELABDATA,
    TBRCQAPROV,
    TBRCQAPROVDATA,
    TBRCQET,
    TBRCQETTIPO,
    CODIGOITEM,
    NOMEITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    CODCLITEM,
    NOMECLITEM)
AS
select
rc, cod, tbrcqrc, tbrcqrcrev, tbrcqtipo, tbrcqsetor, tbrcqobs, tbrcqespcom, tbrcqelab, tbrcqelabdata, tbrcqaprov, tbrcqaprovdata, tbrcqet, tbrcqettipo,
codigoitem, nomeitem, desenhoitem, revdesenhoitem, codclitem, nomeclitem
from  tbrcxcod join tbrcq on (tbrcxcod.rc = tbrcq.tbrcqrc) join tbitensQ on(tbrcxcod.cod = tbitensQ.codigoitem )
;



/* View: HIST */
CREATE VIEW HIST(
    HCODFOR,
    HCODMAT,
    HLOTESINSP,
    HLOTESSK,
    HLOTESNC,
    HESTAGIO,
    HPROXLOTE,
    HULTIR,
    HDATAIR,
    HSEQ,
    HLOTESAI,
    NOMEITEM,
    DESENHOITEM,
    NOMECLITEM)
AS
select hcodfor, hcodmat, hlotesinsp, hlotessk,
hlotesnc, hestagio, hproxlote, hultir, hdatair, hseq, hlotesai,
nomeitem, desenhoitem, nomeclitem from tbhir join rcq on (tbhir.hcodmat = rcq.cod)
;



/* View: HIST2 */
CREATE VIEW HIST2(
    HCODFOR,
    HCODMAT,
    HLOTESINSP,
    HLOTESSK,
    HLOTESNC,
    HESTAGIO,
    HPROXLOTE,
    HULTIR,
    HDATAIR,
    HSEQ,
    HLOTESAI,
    NOMEITEM,
    DESENHOITEM,
    NOMECLITEM)
AS
select hcodfor, hcodmat, hlotesinsp, hlotessk,
hlotesnc, hestagio, hproxlote, hultir, hdatair, hseq, hlotesai,
nomeitem, desenhoitem, nomeclitem from tbhir join tbitensQ on (tbhir.hcodmat = tbitensQ.codigoitem)
;



/* View: HORARIO */
CREATE VIEW HORARIO(
    DATA_CRIACAO,
    HORA_CRIACAO,
    EMISSAO,
    RAZAO,
    NF_NUMERO,
    CFOP,
    DESCCFOP,
    NUMNF)
AS
select data_criacao, hora_criacao, emissao, razao, nf_numero, cfop, desccfop,
numnf  from tbnf
left join tb_log_nfe on tbnf.numnf = numero_nfe
where data_criacao >= '11.11.2009' order by data_criacao, hora_criacao
;



/* View: HORAS_REPARO_POR_OM */
CREATE VIEW HORAS_REPARO_POR_OM(
    OM,
    TEMPO)
AS
select a.id_om as om, sum(a.hs_maq) as tempo
from tb_om_horas a
group by a.id_om
;



/* View: HORAS_MANUTENCAO */
CREATE VIEW HORAS_MANUTENCAO(
    OM,
    DATA_SOLICITACAO,
    HORA_SOLICITACAO,
    DATA_PROGRAMADA,
    HORA_PROGRAMADA,
    DATA_ENCERRADA,
    HORA_ENCERRADA,
    DATA_ANDAMENTO,
    HORA_ANDAMENTO,
    STATUS,
    TIPO_MANUT,
    OBS_TIPO_MANUT,
    NATUREZA_MANUT,
    OBS_NATUREZA_MANUT,
    DESCRICAO_OCORRENCIA,
    SETOR_SOLICITANTE,
    RECURSO,
    OPERADOR,
    OS_VINCULADA,
    SOLICITANTE,
    DESCRICAO_SERVICO,
    CHECK_LIST_VINCULADO,
    INFO_COMPLEMENTAR,
    N_CONT,
    DEFEITO,
    PRAZO_TECNICO,
    DATA_FINAL,
    MINUTOS_PARADOS,
    DESCRICAO_NATUREZA,
    DESCRICAO_TIPO,
    DESCRICAO_STATUS,
    DESCRICAO_MAQUINA,
    DESCRICAO,
    TEMPO_GASTO,
    TEMPO_REPARO,
    DISP_MES,
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    ANO_SOLIC,
    MES_OM,
    REF_MAQ,
    OM_ORIGEM,
    DATA_ORIGEM,
    NOME_GRUPO,
    PRIORIDADE,
    TIPO_M)
AS
select distinct a.om, a.data_solicitacao, a.hora_solicitacao, a.data_programada, a.hora_programada, a.data_encerrada, a.hora_encerrada,
a.data_andamento, a.hora_andamento, a.status, a.tipo_manut,
a.obs_tipo_manut, a.natureza_manut, a.obs_natureza_manut,
a.descricao_ocorrencia, a.setor_solicitante, a.recurso, a.codigo, a.os_vinculada, cast(a.solicitante as int), a.descricao_servico,
a.check_list_vinculado, a.info_complementar, CAST(a.om AS INT),
case
when a.defeito is null then 'NA'
else
a.defeito
end,
a.prazo_tecnico,
f_lastdaymonth(a.data_solicitacao),
case
when a.data_encerrada is null then
        case
        when f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(f_left(f_lastdaymonth(a.data_solicitacao),10)|| ' 23:59' as timestamp)) is null then 0
        else f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(f_left(f_lastdaymonth(a.data_solicitacao),10)|| ' 23:59' as timestamp))
        end
else
        case
        when f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(a.data_encerrada || ' ' || a.hora_encerrada as timestamp)) is null then 0
        else f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(a.data_encerrada || ' ' || a.hora_encerrada as timestamp))
        end
END ,
case
when a.natureza_manut = 1 then 'INDUSTRIAL'
when a.natureza_manut = 2 then 'FERRAMENTARIA'
when a.natureza_manut = 3 then 'SERVI�OS DE TERCEIRO'
when a.natureza_manut = 4 then 'OUTROS'
END,
CASE
WHEN a.TIPO_MANUT = 1 THEN 'CORRETIVA'
WHEN a.TIPO_MANUT = 2 THEN 'PREVENTIVA'
WHEN a.TIPO_MANUT = 3 THEN 'MPT'
WHEN a.TIPO_MANUT = 4 THEN 'OUTROS'
WHEN a.TIPO_MANUT = 5 THEN 'OUTROS'
WHEN a.TIPO_MANUT = 6 THEN 'OUTROS'
END,
CASE
WHEN a.STATUS = 1 THEN 'SOLICITADA'
WHEN a.STATUS = 2 THEN 'PROGRAMADA'
WHEN a.STATUS = 3 THEN 'ANDAMENTO'
WHEN a.STATUS = 4 THEN 'ENCERRADA'
END, recursos.nome_maquina, '', a.tempo_gasto, horas_reparo_por_om.tempo,  recursos.captotmes, f_month(a.data_solicitacao)||'-'||f_year(a.data_solicitacao),
recursos.setor, recursos.nome_setor, f_year(a.data_solicitacao), f_month(a.data_solicitacao),
f_month(a.data_solicitacao)||'-'||f_year(a.data_solicitacao)||a.recurso ,
b.n_cont,

case when b.data_solicitacao is not null then
b.data_solicitacao
else
a.data_solicitacao 
END,

recursos.NOME_GRUPO ,

CASE
WHEN a.TIPO_MANUT = 1 THEN '-'
WHEN a.TIPO_MANUT = 2 THEN '-'
WHEN a.TIPO_MANUT = 3 THEN '-'
WHEN a.TIPO_MANUT = 4 THEN 'LEVE'
WHEN a.TIPO_MANUT = 5 THEN 'M�DIA'
WHEN a.TIPO_MANUT = 6 THEN 'CR�TICA'
END,

CASE
when A.tipo_manut = 1 THEN 'CORRETIVA'
when A.tipo_manut = 2 THEN 'PREVENTIVA'
when A.tipo_manut = 3 THEN 'PREDITIVA'
else 'OUTROS'
end



from tb_om a
left join recursos on (a.recurso = recursos.maquina)
left join horas_reparo_por_om on (a.om = horas_reparo_por_om.om)
left join tb_om b on (a.os_vinculada = b.n_cont)

 where a.data_solicitacao >='01.01.2018'
order by a.om
;



/* View: HORAS_MANUTENCAO_GERAL */
CREATE VIEW HORAS_MANUTENCAO_GERAL(
    OM,
    DATA_SOLICITACAO,
    HORA_SOLICITACAO,
    DATA_PROGRAMADA,
    HORA_PROGRAMADA,
    DATA_ENCERRADA,
    HORA_ENCERRADA,
    DATA_ANDAMENTO,
    HORA_ANDAMENTO,
    STATUS,
    TIPO_MANUT,
    OBS_TIPO_MANUT,
    NATUREZA_MANUT,
    OBS_NATUREZA_MANUT,
    DESCRICAO_OCORRENCIA,
    SETOR_SOLICITANTE,
    RECURSO,
    CODIGO,
    OS_VINCULADA,
    SOLICITANTE,
    DESCRICAO_SERVICO,
    CHECK_LIST_VINCULADO,
    INFO_COMPLEMENTAR,
    N_CONT,
    DEFEITO,
    DATA_FINAL,
    MINUTOS_PARADOS,
    DESCRICAO_NATUREZA,
    DESCRICAO_TIPO,
    DESCRICAO_STATUS,
    DESCRICAO_MAQUINA,
    DESCRICAO,
    TEMPO_GASTO,
    TEMPO_REPARO,
    DISP_MES,
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    ANO_SOLIC,
    MES_OM,
    GRUPO,
    NOME_GRUPO,
    PRAZO_TECNICO)
AS
select tb_om.om, data_solicitacao, hora_solicitacao, data_programada, hora_programada, data_encerrada, hora_encerrada,
data_andamento, hora_andamento, status, tipo_manut, obs_tipo_manut, natureza_manut, obs_natureza_manut,
descricao_ocorrencia, setor_solicitante, tb_om.recurso, codigo, os_vinculada, solicitante, descricao_servico,
check_list_vinculado, info_complementar, n_cont,
case
when defeito is null then 'NA'
else
defeito
end,
f_lastdaymonth(data_solicitacao),
case
when data_encerrada is null then
        case
        when f_minutesbetween(cast(data_solicitacao || ' ' || hora_solicitacao as timestamp), cast(f_left(f_lastdaymonth(data_solicitacao),10)|| ' 23:59' as timestamp)) is null then 0
        else f_minutesbetween(cast(data_solicitacao || ' ' || hora_solicitacao as timestamp), cast(f_left(f_lastdaymonth(data_solicitacao),10)|| ' 23:59' as timestamp))
        end
else
        case
        when f_minutesbetween(cast(data_solicitacao || ' ' || hora_solicitacao as timestamp), cast(data_encerrada || ' ' || hora_encerrada as timestamp)) is null then 0
        else f_minutesbetween(cast(data_solicitacao || ' ' || hora_solicitacao as timestamp), cast(data_encerrada || ' ' || hora_encerrada as timestamp))
        end
END ,
case
when natureza_manut = 1 then 'INDUSTRIAL'
when natureza_manut = 2 then 'FERRAMENTARIA'
when natureza_manut = 3 then 'SERVI�OS DE TERCEIRO'
when natureza_manut = 4 then 'OUTROS'
END,
CASE
WHEN TIPO_MANUT = 1 THEN 'CORRETIVA'
WHEN TIPO_MANUT = 2 THEN 'PREVENTIVA'
WHEN TIPO_MANUT = 3 THEN 'MPT'
WHEN TIPO_MANUT = 4 THEN 'OUTROS'
END,
CASE
WHEN STATUS = 1 THEN 'SOLICITADA'
WHEN STATUS = 2 THEN 'PROGRAMADA'
WHEN STATUS = 3 THEN 'ANDAMENTO'
WHEN STATUS = 4 THEN 'ENCERRADA'
END, recursos.nome_maquina, nomeitem, tb_om.tempo_gasto, horas_reparo_por_om.tempo,  recursos.captotmes, f_month(tb_om.data_solicitacao)||'-'||f_year(tb_om.data_solicitacao),
recursos.setor, recursos.nome_setor, f_year(tb_om.data_solicitacao), f_month(tb_om.data_solicitacao),
RECURSOS.grupo, RECURSOS.nome_grupo, tb_om.prazo_tecnico
from recursos left join tb_om  on (recursos.maquina = tb_om.recurso)
left join tbitens on (tb_om.codigo = tbitens.codigoitem)
left join horas_reparo_por_om on (tb_om.om = horas_reparo_por_om.om)
 where data_solicitacao >='01.01.2018'
order by om
;



/* View: SETORES */
CREATE VIEW SETORES(
    GRUPO,
    NOME_GRUPO,
    MAQUINA,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    NCC,
    CAPTOTDIA,
    CAPTOTMES,
    CAPT1,
    CAPT2,
    CAPT3,
    CAPTDISP,
    TIPO)
AS
select c.idccusto, c.nome, a.idrec, a.nomerec, b.idsetor, b.nomesetor, b.ncc, a.capdisp,
((a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs))*a.dias_disp_mes,

a.t1realhs, a.t2realhs, a.t3realhs ,

((a.t1capqtd * a.t1caphs)+
(a.t2capqtd * a.t2caphs)+
(a.t3capqtd * a.t3caphs))*a.dias_tot_mes, c.tipomo



 from tbrecurso a
left join tbsetor b on (a.idsetor = b.idsetor)
LEFT JOIN ccusto c on (b.idccusto = c.idccusto)
;



/* View: HORAS_PARADAS */
CREATE VIEW HORAS_PARADAS(
    DATA,
    MAQUINA,
    SETOR,
    INICIO,
    TERMINO,
    CODIGO_PARADA,
    MOTIVO,
    TOTAL,
    MES,
    TURNO)
AS
select  a.data, a.maquina, c.nome_setor, a.inicio, a.termino, a.motivo, b.descricao,
(f_timetodouble(a.termino) - f_timetodouble(a.inicio)) * 24, f_padleft(f_month(a.data),'0',2)||'/'||f_year(a.data),
a.turno 
from tb_horas_paradas a
left join tb_motivos_parada b on (a.motivo = b.parada)
left join setores c on (a.maquina = c.maquina)
;



/* View: HORAS_REPARO_POR_OPERADOR */
CREATE VIEW HORAS_REPARO_POR_OPERADOR(
    OM,
    TEMPO,
    JORNADA,
    REGISTRO,
    NOME,
    DIA,
    MES,
    ANO,
    DESCRICAO_OCORRENCIA,
    DESCRICAO_SERVICO,
    SETOR,
    MAQUINA,
    NUMERO_OM,
    POSICAO)
AS
select a.id_om as om, sum(a.hs_maq) as tempo, AVG(b.jornada), a.registro, B.usernome, a.data, f_month(a.data), f_year(a.data)
, COALESCE(c.descricao_ocorrencia,' '), COALESCE(c.descricao_servico,' '), c.setor_solicitante, c.recurso, c.n_cont as numero_om,
'01/'||f_padleft(F_MONTH(A.DATA),'0',2)||'/'||F_YEAR(A.DATA)

from tb_om_horas a
left join tb_user b
on a.registro = b.registro
left join tb_om c
on a.id_om = c.om
group by
a.id_om, a.registro, B.USERnome, a.data, f_month(a.data), f_year(a.data),
c.descricao_ocorrencia, c.descricao_servico, c.setor_solicitante, c.recurso, c.n_cont
;



/* View: ID_RECURSOS */
CREATE VIEW ID_RECURSOS(
    GRUPO,
    NOME_GRUPO,
    MAQUINA,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    NCC,
    TIPO)
AS
select distinct c.idccusto, c.nome, a.idrec, a.nomerec, b.idsetor, b.nomesetor, b.ncc,c.tipomo
from tb_recurso a
left join tbsetor b on (a.idsetor = b.idsetor)
LEFT JOIN ccusto c on (b.idccusto = c.idccusto)
;



/* View: RCVINC */
CREATE VIEW RCVINC(
    RC,
    COD,
    TBRCQRC,
    TBRCQTIPO,
    TBRCQSETOR,
    TBRCQET,
    TBRCQETTIPO,
    MENSAGEMPADRAO)
AS
select rc, cod, tbrcqrc, tbrcqtipo, tbrcqsetor, tbrcqet, tbrcqettipo, mensagempadrao from tbrcxcod
join tbrcq on (tbrcxcod.rc = tbrcq.tbrcqrc) left join tbitensQ on (tbitensQ.codigoitem = tbrcxcod.cod)
;



/* View: IMPORTA_NR */
CREATE VIEW IMPORTA_NR(
    IRDATA,
    IRNUM,
    IRCODFOR,
    IRFORFAN,
    IRRC,
    IRMAT,
    IRCODMAT,
    IRNF,
    IRCERT,
    IRQTD,
    IRUND,
    IRINSPETOR,
    IRREG,
    IRNAT,
    IRBASE,
    IRFORQ,
    BASEIR,
    STATUS,
    GRUPO,
    N_ET,
    CFOP,
    RC,
    ATIVIDADE,
    REGPED,
    REGNF,
    TIPORC)
AS
select sistema, 8 || IDITEMNF, codcli, fantasia, rcvinc.rc, descricao, notasfiscaisc.codigoitem , pedidocli, '',
qtdeitem, und, 'CRISTIANE', 'N', 'I',f_padleft(F_MONTH(SISTEMA),'0',2) || '/'|| f_year(SISTEMA), TBFOR.tbforq ,
f_year(SISTEMA)||f_padleft(F_MONTH(SISTEMA),'0',2), STATUS, tbitens.grupoitem, N_ET, notasfiscaisc.cfop, rcvinc.rc, tbfor.tbfornatfor, notasfiscaisc.iditemnf, notasfiscaisc.iditemped, RCVINC.tbrcqtipo 
from notasfiscaisc LEFT JOIN TBFOR ON (notasfiscaisc.codcli = TBFOR.tbforcod)
left join tbitens on (notasfiscaisc.codigoitem = tbitens.codigoitem)
left join rcvinc on (notasfiscaisc.codigoitem = rcvinc.cod)  WHERE notasfiscaisc.codcli not in (1045,1140) and NOTASFISCAISC.status = 1 AND SISTEMA between '01.08.2010' AND '31.08.2010'
and tbforq in (1,2)  and tbitens.grupoitem in ('16','20') and cfop like '1.124'   and tbfor.tbfornatfor = 'TRATAMENTO SUPERFICIAL'
 and rcvinc.tbrcqtipo not like '%AMASSAR%'
ORDER BY CODCLI, CODIGOITEM, SISTEMA, IDITEMNF
;



/* View: INDICADOR_PRAZO */
CREATE VIEW INDICADOR_PRAZO(
    DATA,
    CODIGO,
    CLIENTE,
    PROGRAMA,
    FATURADO,
    MES,
    TIPO_PRODUTO)
AS
select a.data, a.item, a.cliente, a.pedido, a.faturado,
f_padleft(f_month(a.data),'0',2)||'/'||f_year(a.data),
case
when f_left(a.item,2) = '99' then 'PA'
when f_left(a.item,2) = '98' then 'PI'
else
'NA'
end
from tb_prazos
a order by a.cliente, a.item, a.data, a.pedido desc
;



/* View: TOTAIS_MANUTENCAO */
CREATE VIEW TOTAIS_MANUTENCAO(
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    RECURSO,
    QTD_OM,
    QTD_HORAS,
    QTD_TRAB,
    DISP_MES,
    TIPO_MANUT,
    NATUREZA_MANUT,
    MES,
    ANO)
AS
select mes_solic, setor, nome_setor, recurso, count(n_cont) as qtd_om, sum(tempo_gasto) as parada,
sum(tempo_reparo) as reparo,
disp_mes, natureza_manut, tipo_manut, mes_om, ano_solic
from horas_manutencao where natureza_manut =1 and tipo_manut =1 and data_solicitacao >= '01.01.2017'
group by mes_solic, setor, nome_setor, recurso, natureza_manut, tipo_manut, disp_mes, mes_om, ano_solic
order by setor, recurso, mes_solic
;



/* View: INDICES_MANUTENCAO */
CREATE VIEW INDICES_MANUTENCAO(
    ANO,
    MES,
    SETOR,
    NOME_SETOR,
    RECURSO,
    QTD_OM,
    QTD_HORAS,
    QTD_TRAB,
    DISP_MES,
    TIPO_MANUT,
    NATUREZA_MANUT,
    MTBF,
    MTTR,
    DISPON)
AS
select ano, mes, setor, nome_setor, recurso, qtd_om, QTD_HORAS,
QTD_TRAB, disp_mes, tipo_manut, natureza_manut,
CAST((DISP_MES - QTD_HORAS)/ QTD_OM AS numeric2),
QTD_HORAS/QTD_OM,
((DISP_MES - QTD_HORAS)/ QTD_OM)/(((DISP_MES - QTD_HORAS)/QTD_OM)+(QTD_HORAS/QTD_OM))
from totais_manutencao
;



/* View: IQF_FORNECEDOR */
CREATE VIEW IQF_FORNECEDOR(
    COD_FOR,
    NOME_FOR,
    IQFP,
    IR,
    IE,
    ISP,
    RR,
    LR,
    LRR,
    LAD,
    LRP,
    RCC,
    LEA,
    LFE,
    NC,
    DP,
    MES_BASE,
    MES,
    ANO,
    SITUACAO,
    SERVICO,
    CERTIFICADO,
    DISPOSICAO)
AS
select
IQFFORCOD,
TBFORFAN,
IQFPONTFINAL,
IQFPONTOS,
IQFIQEPONTOS,
IQFAFV,
IQFREDUTOR,
IQFLOTESTOTAL,
IQFLOTESREJ,
IQFLOTESDESVIO,
IQFLOTESUSAR,
IQFLOTESAFETA,
IQFLOTESATRAZO,
IQFLOTESFEXTRA,
IQFNCPEND,
IQFDOCPEND, IQFBASE, IQFNMES, IQFANO, iqfsit, tbfornatfor, tbforcert, iqfstatus
from IQF JOIN TBFOR ON (IQF.iqfforcod = TBFOR.tbforcod)
;



/* View: ISS_RETIDO */
CREATE VIEW ISS_RETIDO(
    ID_PARAMETRO,
    VALOR_INFORMADO,
    NOME_EVENTO,
    NATUREZA,
    ID_NOTA,
    NOTA_FISCAL,
    FORNECEDOR,
    BASE,
    ALIQUOTA,
    DATA)
AS
select a.id_parametro, a.valor_informado, a.nome_evento, b.natureza, a.id_nfc, c.pedidocli, c.codcli, c.valortotalnf
, cast((a.valor_informado/c.valortotalnf)*100 as numeric(5,2)), c.sistema
from tb_eventos_nfc a left join tb_parametros_eventos b on (a.id_parametro = b.id_evento)
left join tbnfc c on (a.id_nfc = c.numnf)
where b.natureza = 'F'
;



/* View: ITEM_ASN */
CREATE VIEW ITEM_ASN(
    NF_NUMERO,
    ITEMCLIENTE,
    QTDEITEM,
    UNDMEDIDA,
    NCM,
    ALIQUOTAIPI,
    VALORUNITARIO,
    ALIQUOTAICMS,
    BASEICMS,
    VALORICMS,
    VALORIPI,
    CST,
    PRECOTOTAL,
    CFOP,
    PEDIDOITEM,
    TIPOPEDIDO,
    PEDIDOSEPPEN,
    LOTEPRODUCAO,
    IDNUMNF)
AS
select b.nf_numero, C.desenhoitem, a.qtdeitem, a.und, a.classfiscal, a.ipi, cast(a.vlunit as numeric(12,2)),
a.icms, a.base_icms, a.valor_icms, a.vlipi, a.sittrib, a.vltot, b.cfop,
c.pedidocli,c.item_ped_cliente, f_replace(c.revdesenhoitem,'-','') , c.posicao,  a.idnumnf
from tbitensnf a left join tbnf b on (a.idnumnf = b.numnf)
left join tbpropitem c on (a.iditemped = c.iditem) order by a.iditemnf
;



/* View: ITENS_COMPRA */
CREATE VIEW ITENS_COMPRA(
    CODIGOITEM,
    NOMEITEM,
    UNDCOMPRAITEM,
    UNDUSOITEM,
    FATORCONVITEM,
    PRECOCOMPRA,
    VALORULTCOMPRA,
    DATAULTCOMPRA,
    ULTFORN)
AS
select
codigoitem, nomeitem, undcompraitem, undusoitem, fatorconvitem, precocompra, valorultcompra, dataultcompra, ultforn
 from tbitens where grupoitem in('16','20') and arvore is null
;



/* View: ITENS_COTADOS */
CREATE VIEW ITENS_COTADOS(
    NUMPED,
    CODCLI,
    FANTASIA,
    APROVACAO,
    CODPROD,
    NOMEPROD,
    IDITEM)
AS
select numped, codcli, fantasia, aprovacao, codprod, nomeprod, IDITEM
from pedido WHERE st IN (1,2,6)
GROUP BY numped, codcli, fantasia, aprovacao, codprod, nomeprod, IDITEM
;



/* View: ITENS_GANHOS */
CREATE VIEW ITENS_GANHOS(
    NUMPED,
    CODCLI,
    FANTASIA,
    APROVACAO,
    CODPROD,
    NOMEPROD,
    ID_ORIGEM,
    PEDI_ORIGEM)
AS
select numped, codcli, fantasia, aprovacao, codprod, nomeprod, id_origem, pedi_origem
from pedido WHERE st IN (3,4,5)
AND ID_ORIGEM <> 0
GROUP BY numped, codcli, fantasia, aprovacao, codprod, nomeprod, id_origem, pedi_origem
;



/* View: ITENS_HEADER_5 */
CREATE VIEW ITENS_HEADER_5(
    NUMNOTA,
    EXIGE_CC,
    CONTA,
    VALOR_TOTAL,
    VALOR_CC,
    CC1,
    GRUPO_1,
    CC2,
    GRUPO_2,
    CC3,
    GRUPO_3,
    CC4,
    GRUPO_4,
    CC5,
    GRUPO_5)
AS
select
idnumnf,
exige_cc,
tbcfop.ctcontdeb,
sum(vltot + tbitensnfc.vlipi + tbitensnfc.item_valor_frete + tbitensnfc.item_valor_seguro + tbitensnfc.item_valor_outros),
sum(CASE when CC5 IS NOT NULL AND CC5 <> 0
AND CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN (vltot + tbitensnfc.vlipi + tbitensnfc.item_valor_frete + tbitensnfc.item_valor_seguro + tbitensnfc.item_valor_outros) / 5
ELSE
CASE WHEN CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN (vltot + tbitensnfc.vlipi + tbitensnfc.item_valor_frete + tbitensnfc.item_valor_seguro + tbitensnfc.item_valor_outros) / 4
ELSE
CASE WHEN CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN (vltot + tbitensnfc.vlipi + tbitensnfc.item_valor_frete + tbitensnfc.item_valor_seguro + tbitensnfc.item_valor_outros) / 3
ELSE
case WHEN CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN (vltot + tbitensnfc.vlipi + tbitensnfc.item_valor_frete + tbitensnfc.item_valor_seguro + tbitensnfc.item_valor_outros) / 2
ELSE
CASE WHEN CC1 is NOT null AND CC1 <> 0
THEN (vltot + tbitensnfc.vlipi + tbitensnfc.item_valor_frete + tbitensnfc.item_valor_seguro + tbitensnfc.item_valor_outros)
else
(vltot + tbitensnfc.vlipi + tbitensnfc.item_valor_frete + tbitensnfc.item_valor_seguro + tbitensnfc.item_valor_outros)
END
END
END
END
END),
case
when tbpropitemc.cc1 is null then '999999'
when tbpropitemc.cc1 = 0 then '999999'
else tbpropitemc.cc1
end,
case when a.grupo is null then '45'
else a.grupo end,
tbpropitemc.cc2,
b.grupo,
tbpropitemc.cc3,
c.grupo,
tbpropitemc.cc4,
d.grupo,
tbpropitemc.cc5,
e.grupo
from tbitensnfc join (tbnfc join tbcfop on (tbnfc.nfcfopi = tbcfop.cfopi)) on (tbitensnfc.idnumnf = tbnfc.numnf)
left join (tbpropitemc left join grupos_cc_all a on (tbpropitemc.cc1 = a.ncc)
LEFT JOIN grupos_cc_all b  on (tbpropitemc.cc2 = b.ncc)
LEFT JOIN grupos_cc_all c  on (tbpropitemc.cc3 = c.ncc)
LEFT JOIN grupos_cc_all d  on (tbpropitemc.cc4 = d.ncc)
LEFT JOIN grupos_cc_all e  on (tbpropitemc.cc5 = e.ncc)
) on (tbitensnfc.iditemped = tbpropitemc.iditem)
where tbcfop.exige_cc = 1 and tbitensnfc.idnumnf > 5098
group by
idnumnf,
exige_cc,
tbcfop.ctcontdeb , /*
vltot,
CASE when CC5 IS NOT NULL AND CC5 <> 0
AND CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 5
ELSE
CASE WHEN CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 4
ELSE
CASE WHEN CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 3
ELSE
case WHEN CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 2
ELSE
CASE WHEN CC1 is NOT null AND CC1 <> 0
THEN VLTOT
END
END
END
END
END, */
case
when tbpropitemc.cc1 is null then '999999'
when tbpropitemc.cc1 = 0 then '999999'
else tbpropitemc.cc1
end,
case when a.grupo is null then '45'
else a.grupo end,
tbpropitemc.cc2,
b.grupo,
tbpropitemc.cc3,
c.grupo,
tbpropitemc.cc4,
d.grupo,
tbpropitemc.cc5,
e.grupo
order by idnumnf
;



/* View: ITENS_HEADER_5_01 */
CREATE VIEW ITENS_HEADER_5_01(
    NUMNOTA,
    CONTA,
    GRUPO_CONTA,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.grupo_1 || itens_header_5.conta, itens_header_5.grupo_1,
sum(itens_header_5.valor_cc)
from itens_header_5
group by itens_header_5.numnota, itens_header_5.grupo_1 || itens_header_5.conta, itens_header_5.grupo_1
;



/* View: ITENS_HEADER_5_02 */
CREATE VIEW ITENS_HEADER_5_02(
    NUMNOTA,
    CONTA,
    GRUPO_CONTA,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.grupo_2 || itens_header_5.conta, itens_header_5.grupo_2,
sum(itens_header_5.valor_cc)
from itens_header_5 where itens_header_5.grupo_2 is not null
group by itens_header_5.numnota, itens_header_5.grupo_2 || itens_header_5.conta, itens_header_5.grupo_2
;



/* View: ITENS_HEADER_5_03 */
CREATE VIEW ITENS_HEADER_5_03(
    NUMNOTA,
    CONTA,
    GRUPO_CONTA,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.grupo_3 || itens_header_5.conta, itens_header_5.grupo_3,
sum(itens_header_5.valor_cc)
from itens_header_5 where itens_header_5.grupo_3 is not null
group by itens_header_5.numnota, itens_header_5.grupo_3 || itens_header_5.conta, itens_header_5.grupo_3
;



/* View: ITENS_HEADER_5_04 */
CREATE VIEW ITENS_HEADER_5_04(
    NUMNOTA,
    CONTA,
    GRUPO_CONTA,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.grupo_4 || itens_header_5.conta, itens_header_5.grupo_4,
sum(itens_header_5.valor_cc)
from itens_header_5 where itens_header_5.grupo_4 is not null
group by itens_header_5.numnota, itens_header_5.grupo_4 || itens_header_5.conta, itens_header_5.grupo_4
;



/* View: ITENS_HEADER_5_05 */
CREATE VIEW ITENS_HEADER_5_05(
    NUMNOTA,
    CONTA,
    GRUPO_CONTA,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.grupo_5 || itens_header_5.conta, itens_header_5.grupo_5,
sum(itens_header_5.valor_cc)
from itens_header_5 where itens_header_5.grupo_5 is not null
group by itens_header_5.numnota, itens_header_5.grupo_5 || itens_header_5.conta, itens_header_5.grupo_5
;



/* View: ITENS_HEADER_5_ALL */
CREATE VIEW ITENS_HEADER_5_ALL(
    NUMNOTA,
    CONTA,
    GRUPO_CONTA,
    VALOR_CONTA)
AS
select numnota, conta, grupo_conta, valor_conta
from itens_header_5_01 union all
select numnota, conta, grupo_conta, valor_conta
from itens_header_5_02 union all
select numnota, conta, grupo_conta, valor_conta
from itens_header_5_03 union all
select numnota, conta, grupo_conta, valor_conta
from itens_header_5_04 union all
select numnota, conta, grupo_conta, valor_conta
from itens_header_5_05
;



/* View: ITENS_HEADER_5_BK */
CREATE VIEW ITENS_HEADER_5_BK(
    ITEMSEQ,
    NUMNOTA,
    IDITEMPED,
    EXIGE_CC,
    CONTA,
    LINHA,
    VALOR_TOTAL,
    VALOR_CC,
    CC1,
    GRUPO_1,
    CC2,
    GRUPO_2,
    CC3,
    GRUPO_3,
    CC4,
    GRUPO_4,
    CC5,
    GRUPO_5)
AS
select
iditemnf,
idnumnf,
tbitensnfc.iditemped,
exige_cc,
tbcfop.ctcontdeb,
5,
vltot,
CASE when CC5 IS NOT NULL AND CC5 <> 0
AND CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 5
ELSE
CASE WHEN CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 4
ELSE
CASE WHEN CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 3
ELSE
case WHEN CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 2
ELSE
CASE WHEN CC1 is NOT null AND CC1 <> 0
THEN VLTOT
END
END
END
END
END,
tbpropitemc.cc1, a.grupo,  tbpropitemc.cc2, B.GRUPO, tbpropitemc.cc3, c.grupo,  tbpropitemc.cc4, d.grupo, tbpropitemc.cc5, e.grupo
from tbitensnfc join (tbnfc join tbcfop on (tbnfc.nfcfopi = tbcfop.cfopi)) on (tbitensnfc.idnumnf = tbnfc.numnf)
left join (tbpropitemc left join grupos_cc a on (tbpropitemc.cc1 = a.ncc)
LEFT JOIN GRUPOS_CC b  on (tbpropitemc.cc2 = b.ncc)
LEFT JOIN GRUPOS_CC c  on (tbpropitemc.cc3 = c.ncc)
LEFT JOIN GRUPOS_CC d  on (tbpropitemc.cc4 = d.ncc)
LEFT JOIN GRUPOS_CC e  on (tbpropitemc.cc5 = e.ncc)
) on (tbitensnfc.iditemped = tbpropitemc.iditem)
where tbcfop.exige_cc = 1
order by idnumnf,iditemnf
;



/* View: ITENS_HEADER_5_SUM */
CREATE VIEW ITENS_HEADER_5_SUM(
    NUMNOTA,
    CONTA,
    GRUPO_CONTA,
    VALOR_CONTA)
AS
select numnota, conta, grupo_conta, SUM(valor_conta)
from itens_header_5_all
GROUP BY numnota, conta, grupo_conta
;



/* View: ITENS_HEADER_6_01 */
CREATE VIEW ITENS_HEADER_6_01(
    NUMNOTA,
    CC,
    GRUPO_CC,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.cc1 , itens_header_5.grupo_1,
sum(itens_header_5.valor_cc)
from itens_header_5
group by itens_header_5.numnota, itens_header_5.cc1 , itens_header_5.grupo_1
;



/* View: ITENS_HEADER_6_02 */
CREATE VIEW ITENS_HEADER_6_02(
    NUMNOTA,
    CC,
    GRUPO_CC,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.cc2 , itens_header_5.grupo_2,
sum(itens_header_5.valor_cc)
from itens_header_5 where grupo_2 is not null
group by itens_header_5.numnota, itens_header_5.cc2 , itens_header_5.grupo_2
;



/* View: ITENS_HEADER_6_03 */
CREATE VIEW ITENS_HEADER_6_03(
    NUMNOTA,
    CC,
    GRUPO_CC,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.cc3 , itens_header_5.grupo_3,
sum(itens_header_5.valor_cc)
from itens_header_5 where grupo_3 is not null
group by itens_header_5.numnota, itens_header_5.cc3 , itens_header_5.grupo_3
;



/* View: ITENS_HEADER_6_04 */
CREATE VIEW ITENS_HEADER_6_04(
    NUMNOTA,
    CC,
    GRUPO_CC,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.cc4 , itens_header_5.grupo_4,
sum(itens_header_5.valor_cc)
from itens_header_5 where grupo_4 is not null
group by itens_header_5.numnota, itens_header_5.cc4 , itens_header_5.grupo_4
;



/* View: ITENS_HEADER_6_05 */
CREATE VIEW ITENS_HEADER_6_05(
    NUMNOTA,
    CC,
    GRUPO_CC,
    VALOR_CONTA)
AS
select
itens_header_5.numnota, itens_header_5.cc5 , itens_header_5.grupo_5,
sum(itens_header_5.valor_cc)
from itens_header_5 where grupo_5 is not null
group by itens_header_5.numnota, itens_header_5.cc5 , itens_header_5.grupo_5
;



/* View: ITENS_HEADER_6_ALL */
CREATE VIEW ITENS_HEADER_6_ALL(
    NUMNOTA,
    CC,
    GRUPO_CC,
    VALOR_CONTA)
AS
select numnota, cc, grupo_cc, valor_conta
from itens_header_6_01 UNION ALL
select numnota, cc, grupo_cc, valor_conta
from itens_header_6_03 UNION ALL
select numnota, cc, grupo_cc, valor_conta
from itens_header_6_03 UNION ALL
select numnota, cc, grupo_cc, valor_conta
from itens_header_6_04 UNION ALL
select numnota, cc, grupo_cc, valor_conta
from itens_header_6_05
;



/* View: ITENS_HEADER_6_SUM */
CREATE VIEW ITENS_HEADER_6_SUM(
    NUMNOTA,
    CC,
    GRUPO_CC,
    VALOR_CONTA)
AS
select numnota, cc, grupo_cc, SUM(valor_conta)
from itens_header_6_all
GROUP BY numnota, cc, grupo_cc
;



/* View: ITENS_HEADER_TESTE */
CREATE VIEW ITENS_HEADER_TESTE(
    NUMNOTA,
    EXIGE_CC,
    CONTA,
    VALOR_TOTAL,
    VALOR_CC,
    CC1,
    GRUPO_1,
    CC2,
    GRUPO_2,
    CC3,
    GRUPO_3,
    CC4,
    GRUPO_4,
    CC5,
    GRUPO_5)
AS
select
idnumnf,
exige_cc,
tbcfop.ctcontdeb,
sum(vltot),
sum(CASE when CC5 IS NOT NULL AND CC5 <> 0
AND CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 5
ELSE
CASE WHEN CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 4
ELSE
CASE WHEN CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 3
ELSE
case WHEN CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 2
ELSE
CASE WHEN CC1 is NOT null AND CC1 <> 0
THEN VLTOT
END
END
END
END
END),
tbpropitemc.cc1, a.grupo,  tbpropitemc.cc2, B.GRUPO, tbpropitemc.cc3, c.grupo,  tbpropitemc.cc4, d.grupo, tbpropitemc.cc5, e.grupo
from tbitensnfc join (tbnfc join tbcfop on (tbnfc.nfcfopi = tbcfop.cfopi)) on (tbitensnfc.idnumnf = tbnfc.numnf)
left join (tbpropitemc left join grupos_cc a on (tbpropitemc.cc1 = a.ncc)
LEFT JOIN GRUPOS_CC b  on (tbpropitemc.cc2 = b.ncc)
LEFT JOIN GRUPOS_CC c  on (tbpropitemc.cc3 = c.ncc)
LEFT JOIN GRUPOS_CC d  on (tbpropitemc.cc4 = d.ncc)
LEFT JOIN GRUPOS_CC e  on (tbpropitemc.cc5 = e.ncc)
) on (tbitensnfc.iditemped = tbpropitemc.iditem)
where tbcfop.exige_cc = 1
group by
idnumnf,
exige_cc,
tbcfop.ctcontdeb , /*
vltot,
CASE when CC5 IS NOT NULL AND CC5 <> 0
AND CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 5
ELSE
CASE WHEN CC4 is NOT null AND CC4 <> 0
AND CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 4
ELSE
CASE WHEN CC3 is NOT null AND CC3 <> 0
AND CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 3
ELSE
case WHEN CC2 is NOT null AND CC2 <> 0
AND CC1 is NOT null AND CC1 <> 0
THEN VLTOT / 2
ELSE
CASE WHEN CC1 is NOT null AND CC1 <> 0
THEN VLTOT
END
END
END
END
END, */
tbpropitemc.cc1, a.grupo,  tbpropitemc.cc2, B.GRUPO, tbpropitemc.cc3, c.grupo,  tbpropitemc.cc4, d.grupo, tbpropitemc.cc5, e.grupo
order by idnumnf
;



/* View: ITENS_NOTA */
CREATE VIEW ITENS_NOTA(
    IDNUMNF,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    VLUNIT,
    IPI,
    ICMS,
    VLITEM,
    VLIPI,
    DESENHO,
    CLASSFISCAL,
    SITTRIB,
    UND,
    TEXTOLEGAL,
    FCONV)
AS
select
idnumnf,
codigoitem,
descricao,
pedidocli,
sum(qtdeitem) as qtdeitem,
vlunit,
ipi,
icms,
sum(vlitem) as vlitem,
sum(vlipi) as vlipi,
desenho,
classfiscal,
sittrib,
und,
textolegal,
fconv
from tbitensnf 
group by
idnumnf,
codigoitem,
descricao,
pedidocli,
vlunit,
ipi,
icms,
desenho,
classfiscal,
sittrib,
und,
textolegal,
fconv
;



/* View: ITENS_NOTA2 */
CREATE VIEW ITENS_NOTA2(
    NOTA,
    CODIGO,
    QTDE_ITEM)
AS
select tbitensnf.idnumnf, tbitensnf.codigoitem, sum(tbitensnf.qtdeitem) from tbitensnf
group by idnumnf, codigoitem
;



/* View: ITENS_NOTAS_ENTRADA */
CREATE VIEW ITENS_NOTAS_ENTRADA(
    ITEMSEQ,
    NUMNOTA,
    LINHA,
    CLASSIFICACAO,
    QUANTIDADE,
    VALOR_TOTAL,
    SITRIB,
    NUM_ORDEM,
    BASE_IPI,
    VAL_IPI,
    VAL_ISENTAS_IPI,
    VAL_OUTRAS_IPI,
    ALIQ_IPI,
    BASE_ICMS,
    BASE_ICMS_SUBST,
    ALIQ_ICMS,
    VALOR_ICMS,
    VAL_DESCONTO,
    CODIGO_SIT_TRIB,
    ALIQIPI)
AS
select
iditemnf,
idnumnf,
'"3"' as linha,
'"'||codigoitem||'"',
'"'||qtdeitem||'"',
'"'||item_total||'"',
'"'||tbcfop.strib||'"',
'"00"' as num_ordem,
case when aliqipi = 0 then
'"'||vlitem||'"'
else
'"0.00"'
end
,
case WHEN ALIQIPI = 0 THEN
'"'||vlipi||'"'
ELSE
'"0.00"'
END,
CASE WHEN ALIQIPI = 2 THEN
case when vlipi = 0 then
'"'||(item_total)||'"'
else
'"'||vlipi||'"'
end
ELSE
'"0.00"'
END as val_isentas_ipi,
CASE WHEN ALIQIPI = 1 THEN
case when vlipi = 0 then 
'"'||(item_total)||'"'
else
'"'||vlipi||'"'
end
ELSE
'"0.00"'
END as val_outras_ipi,
CASE WHEN ALIQIPI = 0 THEN
'"'||ipi||'"'
ELSE
'"0.00"'
END,
/* base icms */
case when aliqicms in (0,3) then
'"'||tbitensnfc.item_base_icms||'"'
else
'"0.00"'
end
,
'"0.00"' as base_icms_subst,
/* aliquota icms */
'"'||tbitensnfc.icms||'"',
case
when tbcfop.aliqicms in (0,3) then
'"'||tbitensnfc.item_valor_icms||'"'
else '"0.00"'
end
,
'"0.00"' as val_desconto,'"'||tbcfop.cst_ipi||'"',
 aliqipi
from tbitensnfc join (tbnfc join tbcfop on (tbnfc.nfcfopi = tbcfop.cfopi)) on (tbitensnfc.idnumnf = tbnfc.numnf)  order by idnumnf,iditemnf
;



/* View: ITENS_NOTAS_SAIDA */
CREATE VIEW ITENS_NOTAS_SAIDA(
    ITEMSEQ,
    NUMNOTA,
    LINHA,
    CLASSIFICACAO,
    QUANTIDADE,
    VALOR_TOTAL,
    SITRIB,
    NUM_ORDEM,
    BASE_IPI,
    VAL_IPI,
    VAL_ISENTAS_IPI,
    VAL_OUTRAS_IPI,
    ALIQ_IPI,
    BASE_ICMS,
    BASE_ICMS_SUBST,
    ALIQ_ICMS,
    VALOR_ICMS,
    VAL_DESCONTO,
    CODIGO_SIT_TRIB)
AS
select
iditemnf,
idnumnf,
'"3"' as linha,
'"'||codigoitem||'"',
'"'||qtdeitem||'"',
'"'||vltot||'"',
'"'||tbcfop.strib||'"',
'"00"' as num_ordem,
'"'||vlitem||'"',
case when aliqipi = 0 then
'"'||vlipi||'"'
else
'"0.00"' end
,
case when aliqipi = 2 then
case when vlipi = 0 then 
'"'||tbitensnf.vlitem||'"'
else
'"'||vlipi||'"'
end
else
'"0.00"' end as val_isentas_ipi,
case when aliqipi = 1 then
case when vlipi = 0 then 
'"'||tbitensnf.vlitem||'"'
else

'"'||vlipi||'"'

end
else
'"0.00"' end as val_outras_ipi,
case when aliqipi = 0 then
'"'||ipi||'"'
else
'"0.00"' end,
case when aliqicms = 0 then
'"'||vlitem||'"'
else
'"0.00"'
end
,

'"0.00"' as base_icms_subst,
case when aliqicms = 0 then
'"'||tbitensnf.icms||'"'
else
'"0.00"'
end,
case when aliqicms = 0 then
'"'||tbitensnf.valor_icms||'"'
else
'"0.00"'
end,
'"0.00"' as val_desconto,
'"'||tbcfop.cst_ipi||'"'
from tbitensnf join (tbnf join tbcfop on (tbnf.nfcfopi = tbcfop.cfopi)) on (tbitensnf.idnumnf = tbnf.numnf)  order by idnumnf,iditemnf
;



/* View: TOTAIS_MANUTENCAO_SETOR */
CREATE VIEW TOTAIS_MANUTENCAO_SETOR(
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    RECURSO,
    QTD_OM,
    QTD_HORAS,
    QTD_TRAB,
    DISP_MES,
    TIPO_MANUT,
    NATUREZA_MANUT,
    ANO_SOLIC,
    MES_OM,
    REF_MAQ)
AS
select b.mes_solic, a.grupo, a.nome_grupo, a.maquina,





count(b.n_cont) as qtd_om,

sum(b.tempo_gasto) as parada,

sum(b.tempo_reparo) as trabalhado,

a.captotmes, b.natureza_manut, b.tipo_manut, b.ano_solic, b.mes_om, B.mes_solic||A.maquina
from setores a LEFT join horas_manutencao b on a.maquina = b.recurso
where b.natureza_manut = 1 and b.tipo_manut = 1
group by b.mes_solic, a.grupo, a.nome_grupo, a.maquina,
a.captotmes, b.natureza_manut, b.tipo_manut, b.ano_solic, b.mes_om, B.mes_solic||A.maquina
order by a.grupo, a.maquina, b.ano_solic, b.mes_om
;



/* View: KPI_MANUTENCAO */
CREATE VIEW KPI_MANUTENCAO(
    SETOR,
    NOME_SETOR,
    RECURSO,
    JAN_OM,
    JAN_HS,
    FEV_OM,
    FEV_HS,
    MAR_OM,
    MAR_HS,
    ABR_OM,
    ABR_HS,
    MAI_OM,
    MAI_HS,
    JUN_OM,
    JUN_HS,
    JUL_OM,
    JUL_HS,
    AGO_OM,
    AGO_HS,
    SET_OM,
    SET_HS,
    OUT_OM,
    OUT_HS,
    NOV_OM,
    NOV_HS,
    DEZ_OM,
    DEZ_HS,
    DISP_MES,
    ANO_SOLIC)
AS
select a.setor, a.nome_setor, a.recurso ,
case
when a.mes_om = 1 then a.qtd_om else 0 end,
case
when a.mes_om = 1 then a.qtd_horas else 0 end,
case
when a.mes_om = 2 then a.qtd_om else 0 end,
case
when a.mes_om = 2 then a.qtd_horas else 0 end,
case
when a.mes_om = 3 then a.qtd_om else 0 end,
case
when a.mes_om = 3 then a.qtd_horas else 0 end,
case
when a.mes_om = 4 then a.qtd_om else 0 end,
case
when a.mes_om = 4 then a.qtd_horas else 0 end,
case
when a.mes_om = 5 then a.qtd_om else 0 end,
case
when a.mes_om = 5 then a.qtd_horas else 0 end,
case
when a.mes_om = 6 then a.qtd_om else 0 end,
case
when a.mes_om = 6 then a.qtd_horas else 0 end,
case
when a.mes_om = 7 then a.qtd_om else 0 end,
case
when a.mes_om = 7 then a.qtd_horas else 0 end,
case
when a.mes_om = 8 then a.qtd_om else 0 end,
case
when a.mes_om = 8 then a.qtd_horas else 0 end,
case
when a.mes_om = 9 then a.qtd_om else 0 end,
case
when a.mes_om = 9 then a.qtd_horas else 0 end,
case
when a.mes_om = 10 then a.qtd_om else 0 end,
case
when a.mes_om = 10 then a.qtd_horas else 0 end,
case
when a.mes_om = 11 then a.qtd_om else 0 end,
case
when a.mes_om = 11 then a.qtd_horas else 0 end,
case
when a.mes_om = 12 then a.qtd_om else 0 end,
case
when a.mes_om = 12 then a.qtd_horas else 0 end,
a.disp_mes, a.ano_solic
from totais_manutencao_setor a
group by a.setor, a.nome_setor, a.recurso,
case
when a.mes_om = 1 then a.qtd_om else 0 end,
case
when a.mes_om = 1 then a.qtd_horas else 0 end,
case
when a.mes_om = 2 then a.qtd_om else 0 end,
case
when a.mes_om = 2 then a.qtd_horas else 0 end,
case
when a.mes_om = 3 then a.qtd_om else 0 end,
case
when a.mes_om = 3 then a.qtd_horas else 0 end,
case
when a.mes_om = 4 then a.qtd_om else 0 end,
case
when a.mes_om = 4 then a.qtd_horas else 0 end,
case
when a.mes_om = 5 then a.qtd_om else 0 end,
case
when a.mes_om = 5 then a.qtd_horas else 0 end,
case
when a.mes_om = 6 then a.qtd_om else 0 end,
case
when a.mes_om = 6 then a.qtd_horas else 0 end,
case
when a.mes_om = 7 then a.qtd_om else 0 end,
case
when a.mes_om = 7 then a.qtd_horas else 0 end,
case
when a.mes_om = 8 then a.qtd_om else 0 end,
case
when a.mes_om = 8 then a.qtd_horas else 0 end,
case
when a.mes_om = 9 then a.qtd_om else 0 end,
case
when a.mes_om = 9 then a.qtd_horas else 0 end,
case
when a.mes_om = 10 then a.qtd_om else 0 end,
case
when a.mes_om = 10 then a.qtd_horas else 0 end,
case
when a.mes_om = 11 then a.qtd_om else 0 end,
case
when a.mes_om = 11 then a.qtd_horas else 0 end,
case
when a.mes_om = 12 then a.qtd_om else 0 end,
case
when a.mes_om = 12 then a.qtd_horas else 0 end,
a.disp_mes, a.ano_solic
;



/* View: KPI_MTBF */
CREATE VIEW KPI_MTBF(
    SETOR,
    NOME_SETOR,
    RECURSO,
    JAN_OM,
    JAN_HS,
    FEV_OM,
    FEV_HS,
    MAR_OM,
    MAR_HS,
    ABR_OM,
    ABR_HS,
    MAI_OM,
    MAI_HS,
    JUN_OM,
    JUN_HS,
    JUL_OM,
    JUL_HS,
    AGO_OM,
    AGO_HS,
    SET_OM,
    SET_HS,
    OUT_OM,
    OUT_HS,
    NOV_OM,
    NOV_HS,
    DEZ_OM,
    DEZ_HS,
    DISP_MES,
    ANO_SOLIC)
AS
select a.setor, a.nome_setor, a.recurso ,
sum(case
when a.mes = 1 then a.qtd_om else 0 end),
sum(case
when a.mes = 1 then a.qtd_horas else 0 end),
sum(case
when a.mes = 2 then a.qtd_om else 0 end),
sum(case
when a.mes = 2 then a.qtd_horas else 0 end),
sum(case
when a.mes = 3 then a.qtd_om else 0 end),
sum(case
when a.mes = 3 then a.qtd_horas else 0 end),
sum(case
when a.mes = 4 then a.qtd_om else 0 end),
sum(case
when a.mes = 4 then a.qtd_horas else 0 end),
sum(case
when a.mes = 5 then a.qtd_om else 0 end),
sum(case
when a.mes = 5 then a.qtd_horas else 0 end),
sum(case
when a.mes = 6 then a.qtd_om else 0 end),
sum(case
when a.mes = 6 then a.qtd_horas else 0 end),
sum(case
when a.mes = 7 then a.qtd_om else 0 end),
sum(case
when a.mes = 7 then a.qtd_horas else 0 end),
sum(case
when a.mes = 8 then a.qtd_om else 0 end),
sum(case
when a.mes = 8 then a.qtd_horas else 0 end),
sum(case
when a.mes = 9 then a.qtd_om else 0 end),
sum(case
when a.mes = 9 then a.qtd_horas else 0 end),
sum(case
when a.mes = 10 then a.qtd_om else 0 end),
sum(case
when a.mes = 10 then a.qtd_horas else 0 end),
sum(case
when a.mes = 11 then a.qtd_om else 0 end),
sum(case
when a.mes = 11 then a.qtd_horas else 0 end),
sum(case
when a.mes = 12 then a.qtd_om else 0 end),
sum(case
when a.mes = 12 then a.qtd_horas else 0 end),
a.disp_mes, a.ano
from indices_manutencao a
group by
a.setor, a.nome_setor, a.recurso ,
a.disp_mes, a.ano
;



/* View: KPI_PRAZO */
CREATE VIEW KPI_PRAZO(
    ID,
    CLIENTE,
    MES,
    CODIGO,
    PROGRAMA,
    FATURADO,
    PRAZO,
    ATRASO)
AS
select 1, a.cliente, a.mes, a.codigo,
sum(a.programa), sum(a.faturado),
case
when (sum(a.programa)-sum(a.faturado))<=0 then 1
else 0
end,
case
when (sum(a.programa)-sum(a.faturado))>0 then 1
else 0
end
from indicador_prazo a
where a.tipo_produto in ('PA','PI')
group by a.cliente, a.mes, a.codigo
;



/* View: LANCAMENTOS_RECEBIDOS */
CREATE VIEW LANCAMENTOS_RECEBIDOS(
    CODIGOMAT,
    QTDENTRADA,
    MES_LANC,
    VALOR_TOTAL,
    TIPO_ITEM,
    UND)
AS
select codigomat, sum(qtd_mov), mes_lanc, cast(sum(valor_mov) as digito16), movimento_recebido.tipo_item, movimento_recebido.und
from movimento_recebido  where grupo in (0,1) group by codigomat, mes_lanc, tipo_item, movimento_recebido.und
having (f_stringlength(codigomat) > 1
and sum(movimento_recebido.valor_mov) <> 0 and sum(qtd_mov)<>0) /* and sum(valor_total) > 0 */
order by codigomat
;



/* View: LISTA_AUDITORIAS */
CREATE VIEW LISTA_AUDITORIAS(
    ID_REGISTRO,
    ID_AUDITORIA,
    COD_ENTIDADE,
    DATA_CRIACAO,
    PRAZO_AUDITORIA,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    AUDITOR,
    NOME_AUDITORIA,
    TIPO_AUDITORIA,
    ENTIDADE,
    NOME_AUDITOR)
AS
select id_registro, id_auditoria, cod_entidade, data_criacao, prazo_auditoria, nota_avaliacao, status_avaliacao, prox_auditoria, auditor, nome_auditoria, tipo_auditoria, entidade, nome_auditor
from auditoria_fornecedor union ALL
select id_registro, id_auditoria, cod_entidade, data_criacao, prazo_auditoria, nota_avaliacao, status_avaliacao, prox_auditoria, auditor, nome_auditoria, tipo_auditoria, entidade, nome_auditor
from auditoria_processo UNION all
select id_registro, id_auditoria, cod_entidade, data_criacao, prazo_auditoria, nota_avaliacao, status_avaliacao, prox_auditoria, auditor, nome_auditoria, tipo_auditoria, entidade, nome_auditor
from auditoria_produto UNION ALL
select id_registro, id_auditoria, cod_entidade, data_criacao, prazo_auditoria, nota_avaliacao, status_avaliacao, prox_auditoria, auditor, nome_auditoria, tipo_auditoria, entidade, nome_auditor
from auditoria_sistema
;



/* View: LISTA_CONTATOS */
CREATE VIEW LISTA_CONTATOS(
    NOME,
    SETOR,
    EMPRESA,
    RAMAL,
    FONE,
    CELULAR,
    RADIO,
    EMAIL)
AS
select  nomecontato,depart,tbfor.tbforfan ,ramalfone, fone, celular, '', mail
from tbcontato left join tbfor on (tbcontato.idfor = tbfor.tbforcod)
;



/* View: LISTA_MATERIAIS */
CREATE VIEW LISTA_MATERIAIS(
    ARVORE,
    IDPROC,
    TIPO,
    SEQ,
    VR_CUSTO,
    PRODUTO)
AS
select tbarvoremat.arvore ,tbarvoremat.destino ,  1, tbarvoremat.seq,  tbarvoremat.customat , tbarvoremat.produto
from tbarvoremat order by arvore, mnum
;



/* View: LISTACLI */
CREATE VIEW LISTACLI(
    TBFORCOD,
    TBFORFAN,
    TBFORRAZ,
    TBFORCONT,
    TBFORFONE,
    TBFORFONERAMAL,
    TBFORFAX,
    TBFORFAXRAMAL,
    TBFORMAIL,
    TBFORCEL,
    TBFORCNPJ,
    TBFORINSCMUN,
    TBFORINSCEST,
    TBFORDATA,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORTIPO,
    TBFORNATFOR,
    TBFORCLIFOR,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCPAG,
    TBFORLIMITE,
    TBFORVLIMITE,
    TBFORBLOQ,
    TBFORESP,
    TBFOROBSCOM,
    TBFOROBSFIN,
    TBFORCODVEN,
    TBFORREGIAO,
    TBFORSUFRAMA,
    TBFORVALSUFRAMA,
    TBFORMOTBLOQ,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    TBFORCOMPAD,
    TBFORDEPART,
    TBFORCFOP,
    TBFORDESCCFOP,
    TBFORCODANT,
    TBCFOI,
    CODIGO_FINANCEIRO,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    CODIGO_PAIS,
    TBFORFLAG2,
    PRODUTOR_RURAL,
    FORNECEDOR_ST,
    SIMPLES_NACIONAL,
    INSCRITO_MUNICIPIO,
    CONTA_CONTABIL,
    PLANTA)
AS
select tbforcod, tbforfan, tbforraz, tbforcont, tbforfone, tbforfoneramal, tbforfax, tbforfaxramal, tbformail, tbforcel, tbforcnpj, tbforinscmun, tbforinscest, tbfordata, tbforender, tbforbairro, tbforcep, tbforcid, tbforest, tbfortipo, tbfornatfor, tbforclifor, tbforendercob, tbforbairrocob, tbforcepcob, tbforcidcob, tbforestcob, tbforenderent, tbforbairroent, tbforcepent, tbforcident, tbforestent, tbforcpag, tbforlimite, tbforvlimite, tbforbloq, tbforesp, tbforobscom, tbforobsfin, tbforcodven,tbforregiao, tbforsuframa, tbforvalsuframa, tbformotbloq, tbforcodtransp, tbfornometransp, tbforcompad,tbfordepart, tbforcfop, tbfordesccfop, tbforcodant, tbcfoi,
codigo_financeiro, codigo_municipio, codigo_uf, endereco_numero, complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob, codigo_pais, tbforflag2,produtor_rural, fornecedor_st, simples_nacional, inscrito_municipio, conta_contabil, tbforcheck1 from tbfor
;



/* View: LOTE_ENDERECO */
CREATE VIEW LOTE_ENDERECO(
    QTDE,
    LOTE,
    TIPO,
    IDREC,
    IDSETOR,
    NOMEREC,
    NOMESETOR,
    OS_DESTINO)
AS
select sum(qtde), lote, tipo, idrec, idsetor, nomerec, nomesetor, os_destino
from etiquetas_lote
where tipo = 0 and os_destino = 0
group by lote, tipo, idrec, idsetor, nomerec, nomesetor, os_destino
;



/* View: LOTES_ENTRADA */
CREATE VIEW LOTES_ENTRADA(
    ORIGEM,
    DATA,
    OS,
    LOTE,
    OS_LOTE,
    CODIGO,
    QTDE,
    SALDO,
    TIPO,
    GRUPO)
AS
select 'RECEBIMENTO', TBLOTE.entrada, TBLOTE.os, TBLOTE.lote,
case when tblote.os > 0 then tblote.os
when tblote.os = 0 then tblote.lote 
end,

 TBLOTE.codigoitem, TBLOTE.qtdetotal, TBLOTE.saldolote, TBLOTE.tipo, 0 from TBLOTE
ORDER BY TBLOTE.entrada
;



/* View: LOTES_MOVIMENTO */
CREATE VIEW LOTES_MOVIMENTO(
    ORIGEM,
    DATA,
    LOTE,
    CODIGO,
    QTDE,
    SALDO,
    TIPO,
    GRUPO)
AS
select 'MOVIMENTO', MOVIMENTO.datalanc ,  MOVIMENTO.lote , MOVIMENTO.codigomat , MOVIMENTO.qtd_mov , 0, 0, movimento.grupo  from MOVIMENTO
WHERE MOVIMENTO.grupo IN(1,2) ORDER BY MOVIMENTO.grupo, MOVIMENTO.datalanc
;



/* View: LOTES_CONCILIACAO */
CREATE VIEW LOTES_CONCILIACAO(
    ORIGEM,
    DATA,
    LOTE,
    CODIGO,
    QTDE,
    SALDO,
    TIPO,
    GRUPO)
AS
select origem, data, lote, codigo, qtde, saldo, tipo, grupo
from lotes_entrada UNION ALL
select origem, data, lote, codigo, qtde, saldo, tipo, grupo
from lotes_MOVIMENTO
;



/* View: LOTES_INVENTARIO */
CREATE VIEW LOTES_INVENTARIO(
    PRODUTO,
    QTDE,
    VRTOTAL,
    UNITARIO,
    MES,
    ANO,
    STATUS,
    LOTE,
    OS,
    TIPO,
    TIPO_ITEM)
AS
select tb_inv_est.produto,
case
when tb_inv_est.contagem2 > 0 then tb_inv_est.contagem2 
else tb_inv_est.contagem1 
end, 
case
when tb_inv_est.contagem2 > 0 then tb_inv_est.contagem2 * tb_inv_est.vrunit 
else tb_inv_est.contagem1 * tb_inv_est.vrunit 
end, 
tb_inv_est.vrunit,
'01',
'2011',
'SALDO FINAL',
TB_INV_EST.lote,
TB_INV_EST.os, TB_INV_EST.tipo, TBITENS.tipoitem 
FROM tb_inv_est left join tbITENS on (tb_inv_est.PRODUTO = TBITENS.codigoitem) WHERE TB_INV_EST.tipo IN ('PA','MP','CC','CF') AND TB_INV_EST.origem = 'INV'
;



/* View: LOTES_INVENTARIO_PR */
CREATE VIEW LOTES_INVENTARIO_PR(
    PRODUTO,
    QTDE,
    VRTOTAL,
    UNITARIO,
    MES,
    ANO,
    STATUS,
    LOTE,
    OS,
    TIPO,
    TIPO_ITEM)
AS
select tb_inv_est.produto,
case
when tb_inv_est.contagem2 > 0 then tb_inv_est.contagem2 
else tb_inv_est.contagem1 
end, 
case
when tb_inv_est.contagem2 > 0 then tb_inv_est.contagem2 * tb_inv_est.vrunit 
else tb_inv_est.contagem1 * tb_inv_est.vrunit 
end, 
tb_inv_est.vrunit,
'01',
'2011',
'SALDO FINAL',
TB_INV_EST.lote,
TB_INV_EST.os, TB_INV_EST.tipo, TBITENS.tipoitem 
FROM tb_inv_est left join tbITENS on (tb_inv_est.PRODUTO = TBITENS.codigoitem) WHERE TB_INV_EST.tipo IN ('PR') AND TB_INV_EST.origem = 'INV'
;



/* View: MARGEM_BRUTA */
CREATE VIEW MARGEM_BRUTA(
    ID,
    CODCLI,
    FANTASIA,
    CODIGO,
    PARTNUMBER,
    DESCRICAO,
    OS,
    QTDFATURADA,
    VALORUNITLIQ,
    VALORTOTALLIQ,
    VALORMP,
    VALORCOMPONENTE,
    CUSTOUNITARIO,
    TOTALMP,
    TOTALCOMPONENTE,
    VALORTOTAL,
    MARGEM,
    MES,
    UND,
    CFOP,
    UF,
    ICMS,
    PIS,
    COFINS,
    IMPOSTOS,
    USUARIO)
AS
select a.id, a.codcli, b.tbforfan, a.codigo, c.desenhoitem, c.nomeitem, a.os, a.qtdfaturada, a.valorunitliq, a.valortotalliq,
a.valormp, a.valorcomponente,
cast(a.valormp + a.valorcomponente as digito4),
cast(a.valormp * a.qtdfaturada as digito4), cast(a.valorcomponente * a.qtdfaturada as digito4),
cast(a.valormp * a.qtdfaturada as digito4) + cast(a.valorcomponente * a.qtdfaturada as digito4),
cast((a.valortotalliq - (cast(a.valormp * a.qtdfaturada as digito4) + cast(a.valorcomponente * a.qtdfaturada as digito4)))/a.valortotalliq as digito4),
a.mes, a.und, a.cfop, a.uf, a.icms, a.pis, a.cofins, a.impostos, a.usuario
from tb_margem_faturamento a left join tbfor b on (a.codcli = b.tbforcod)
left join tbitens c on (a.codigo = c.codigoitem)
;



/* View: MARGEM_RECEITA_DESPESA */
CREATE VIEW MARGEM_RECEITA_DESPESA(
    GRUPO,
    NOME,
    ANO,
    JANEIRO,
    FEVEREIRO,
    MARCO,
    ABRIL,
    MAIO,
    JUNHO,
    JULHO,
    AGOSTO,
    SETEMBRO,
    OUTUBRO,
    NOVEMBRO,
    DEZEMBRO)
AS
select 1, nome, ano, janeiro, fevereiro, marco, abril, maio, junho, julho, agosto, setembro, outubro, novembro, dezembro
from cross_fat_ano where ano = 2015
union all
select 2, nome, ano, janeiro*-1, fevereiro*-1, marco*-1, abril*-1, maio*-1, junho*-1, julho*-1, agosto*-1, setembro*-1, outubro*-1, novembro*-1, dezembro*-1
from cross_mp_ano where ano = 2015
union all
select 3, nome, ano, janeiro*-1, fevereiro*-1, marco*-1, abril*-1, maio*-1, junho*-1, julho*-1, agosto*-1, setembro*-1, outubro*-1, novembro*-1, dezembro*-1
from cross_outros_ano where ano = 2015
;



/* View: MATERIAIS_LIBERADOS */
CREATE VIEW MATERIAIS_LIBERADOS(
    TIPO_ITEM,
    CODIGOMAT,
    NOMEITEM,
    REFITEM,
    COMPRIMITEM,
    LARGURAITEM,
    ESPESSURAITEM,
    COD_PARAMETRO,
    OS,
    LOTE,
    QTDSAIDA,
    UND,
    IDPAI,
    ID,
    N_REC,
    N_SETOR,
    NOME_SETOR,
    N_OP,
    OS_ORIGEM,
    IDPROC)
AS
select A.tipo_item,  a.codigomat, d.nomeitem, d.refitem, d.comprimitem, d.larguraitem, d.espessuraitem,  a.cod_parametro, a.os,  a.lote,
case
when a.cod_parametro = '03.10'
then a.qtdereserv
when a.cod_parametro = '03.09'
then a.qtdsaida
end
, a.und, b.idpai, c.id,  c.rec_1 , c.setor, c.nome_setor, c.seq, E.os, c.idproc
from movimento a left join (estrut_os b left join estrut_os c on (b.idpai = c.id)) on (a.os = b.n_os and a.codigomat = b.codigo)
left join tbitens d on (a.codigomat = d.codigoitem) LEFT JOIN TBLOTE E ON (A.lote = E.lote)
 where a.cod_parametro in ('03.10', '03.09')
and b.tipo_est = '0'
;



/* View: NOTAS_SERV */
CREATE VIEW NOTAS_SERV(
    NF_NUMERO,
    NUMNF,
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    VALORICMS,
    VALORIPI,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    VLITEMIPI,
    IPI,
    ICMS,
    DESENHO,
    NUMPED,
    FCONV,
    STACOM,
    COMPLEM,
    NOTA,
    UNIDADE,
    N_OS)
AS
select
nf_numero, numnf, emissao, codcli,NFCFOPI,CFOP,DESCCFOP, razao, fantasia,VALORTOTALNF,TBNF.valoricms, TBNF.valoripi, tipo, canc, vend, TBNF.status, NOMEVEND,
iditemnf, iditemped, codigoitem,DESCRICAO, tbitensnf.pedidocli, qtdeitem,und, vlunit, vlitem,tbitensnf.vlipi,IPI,TBNF.icms ,  desenho, numped, FCONV, STACOM, tbitensnf.textolegal, tipos_saidas.nota, tbnf.unidade,
tbitensnf.n_os 
from tbnf join tipos_saidas join tbitensnf on(tbnf.stacom = tipos_saidas.id) on (idnumnf = numnf) WHERE TBNF.stacom = 2 and emissao >='01.10.2010'
;



/* View: NOTASFISCAISC4 */
CREATE VIEW NOTASFISCAISC4(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    DESENHO,
    NUMPED,
    IPI,
    ICMS,
    VLTOT,
    VLIPI,
    NR,
    NFRECUSA,
    NFSAIDA,
    N_OS,
    N_ET,
    QTD_VOL,
    VOLUME,
    ESPECIFICACAO,
    UNIDADE,
    PESO_LIQ,
    CC1,
    CC2,
    CC3,
    CC4,
    CC5,
    CNPJ,
    STAEST)
AS
select
tbnfc.numnf, tbnfc.emissao,sistema, tbnfc.codcli,tbnfc.NFCFOPI, tbnfc.CFOP,tbnfc.desccfop,  tbnfc.razao, tbnfc.fantasia,VALORTOTALNF, tbnfc.tipo, tbnfc.canc, tbnfc.vend, TBNFC.status, tbnfc.NOMEVEND,
tbitensnfc.iditemnf, tbitensnfc.iditemped, tbitensnfc.codigoitem, tbitensnfc.DESCRICAO, tbNFC.pedidocli, tbitensnfc.qtdeitem,tbitensnfc.und, tbitensnfc.vlunit, tbitensnfc.vlitem, tbitensnfc.desenho, tbitensnfc.numped ,
tbitensnfc.ipi, tbnfc.icms, vltot, vlipi, nr, nfrecusa, TBITENSNFC.nfsaida , notas_serv.n_os ,
case tbpropitemc.et
when '000-' then '0000'
when '-' then '0000'
when '' then '0000'
else f_padleft(tbpropitemc.et,'0',4)
end
,tbitensnfc.sittrib,TBITENSNFC.classfiscal,  tbpropitemc.descorcam, tbnfc.unidade,
tbitens.pesoliqitem, tbpropitemc.cc1, tbpropitemc.cc2,  tbpropitemc.cc3, tbpropitemc.cc4,  tbpropitemc.cc5 , tbnfc.cnpjcli,
tbnfc.staest 
from tbnfc join tbitensnfc left join tbpropitemc on(tbpropitemc.iditem = tbitensnfc.iditemped) on (idnumnf = numnf)
left join tbitens on (tbitensnfc.codigoitem = tbitens.codigoitem)
left join notas_serv on (tbitensnfc.nfsaida  = cast(notas_serv.nf_numero as varchar(20)) and tbitensnfc.codigoitem = notas_serv.codigoitem)
where tbnfc.sistema >= '01.09.2010'
;



/* View: SERVICOS_ENTRADA */
CREATE VIEW SERVICOS_ENTRADA(
    CODFOR,
    NOME_FORNECEDOR,
    DATA_MOV,
    CODIGOITEM,
    DESCRICAO_ITEM,
    SERVICO,
    OS,
    NF_SAIDA,
    NF_ENTRADA,
    QTD_MOV,
    UND,
    NR,
    ORIGEM)
AS
select notasfiscaisc4.codcli , notasfiscaisc4.razao , notasfiscaisc4.sistema , notasfiscaisc4.codigoitem,
notasfiscaisc4.descricao , notasfiscaisc4.especificacao , notasfiscaisc4.n_os  , notasfiscaisc4.nfsaida,    notasfiscaisc4.pedidocli , (notasfiscaisc4.qtdeitem)*-1,
notasfiscaisc4.und  ,notasfiscaisc4.nr , 1 from notasFISCAISC4
where notasfiscaisc4.status = 1
order by notasfiscaisc4.codcli, notasfiscaisc4.sistema , notasfiscaisc4.codigoitem
;



/* View: SERVICOS_SAIDA */
CREATE VIEW SERVICOS_SAIDA(
    CODFOR,
    NOME_FORNECEDOR,
    DATA_MOV,
    CODIGOITEM,
    DESCRICAO_ITEM,
    SERVICO,
    OS,
    NF_SAIDA,
    NF_ENTRADA,
    QTD_MOV,
    UND,
    NR,
    ORIGEM)
AS
select notas_serv.codcli, notas_serv.razao, notas_serv.emissao, notas_serv.codigoitem,
notas_serv.descricao, notas_serv.complem, notas_serv.n_os , notas_serv.nf_numero,0, notas_serv.qtdeitem,
notas_serv.und, 0, 0 from notas_serv order by notas_serv.codcli, notas_serv.emissao, notas_serv.codigoitem
;



/* View: MATERIAL_TERCEIRO */
CREATE VIEW MATERIAL_TERCEIRO(
    CODFOR,
    NOME_FORNECEDOR,
    DATA_MOV,
    CODIGOITEM,
    DESCRICAO_ITEM,
    SERVICO,
    OS,
    NF_SAIDA,
    NF_ENTRADA,
    QTD_MOV,
    UND,
    NR,
    ORIGEM)
AS
select codfor, nome_fornecedor, data_mov, codigoitem, descricao_item, servico, os, nf_saida, nf_entrada, qtd_mov, und, nr, origem
from servicos_saida union all
select codfor, nome_fornecedor, data_mov, codigoitem, descricao_item, servico, os, nf_saida, nf_entrada, qtd_mov, und, nr, origem
from servicos_entrada
;



/* View: MIGRA_FORNECEDORES */
CREATE VIEW MIGRA_FORNECEDORES(
    TBFORCOD,
    TBFORFAN,
    TBFORUND,
    TBFORRAZ,
    TBFORAPP,
    TBFORAPVAL,
    TBFORIQEV,
    TBFORREDUTOR,
    TBFORAFP,
    TBFORAFVAL,
    TBFOROBS,
    TBFORIQF,
    TBFORIQFBASE,
    TBFORPPM,
    TBFORPPMBASE,
    TBFORPPMAC,
    TBFORIQFFINAL,
    TBFORSITIQF,
    TBFORAFCERT,
    TBFORAPV,
    TBFORAFV,
    TBFORCONT,
    TBFORFONE,
    TBFORFONERAMAL,
    TBFORFAX,
    TBFORFAXRAMAL,
    TBFORMAIL,
    TBFORCEL,
    TBFORCNPJ,
    TBFORINSCMUN,
    TBFORINSCEST,
    TBFORDATA,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORTIPO,
    TBFORIQFP,
    TBFORESTAGIO,
    TBFORNATINSP,
    TBFORLOTESINSP,
    TBFORSKLOTES,
    TBFORCOMPL,
    TBFORPLANO,
    TBFORPLANOPRAZO,
    TBFORPLANORESP,
    TBFORFLAG1,
    TBFORFLAG2,
    TBFORCHECK1,
    TBFORCHECK2,
    TBFORULTNR,
    TBFORDATANR,
    TBFORLOTESATESK,
    TBFORVALIDADE,
    TBFORCERT,
    TBFORIQEP,
    TBFORNATFOR,
    TBFORCLIFOR,
    TBFORQ,
    TBFORDATAQ,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCPAG,
    TBFORLIMITE,
    TBFORVLIMITE,
    TBFORBLOQ,
    TBFORESP,
    TBFOROBSCOM,
    TBFOROBSFIN,
    TBFORCODVEN,
    TBFORREGIAO,
    TBFORSUFRAMA,
    TBFORVALSUFRAMA,
    TBFORMOTBLOQ,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    TBFORCOMPAD,
    TBFORDEPART,
    TBFORCFOP,
    TBFORDESCCFOP,
    TBFORCODANT,
    TBCFOI,
    CODIGO_FINANCEIRO,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    CODIGO_PAIS,
    PRODUTOR_RURAL,
    FORNECEDOR_ST,
    SIMPLES_NACIONAL,
    INSCRITO_MUNICIPIO,
    CONTA_CONTABIL,
    PLASTICOS_CNPJ,
    PLASTICOS_RAZAO,
    PLASTICOS_FANTASIA,
    PLASTICOS_CODFOR)
AS
select a.tbforcod, a.tbforfan, a.tbforund, a.tbforraz, a.tbforapp, a.tbforapval, a.tbforiqev, a.tbforredutor, a.tbforafp, a.tbforafval, a.tbforobs, a.tbforiqf, a.tbforiqfbase, a.tbforppm, a.tbforppmbase, a.tbforppmac, a.tbforiqffinal, a.tbforsitiqf, a.tbforafcert, a.tbforapv, a.tbforafv, a.tbforcont, a.tbforfone, a.tbforfoneramal, a.tbforfax, a.tbforfaxramal, a.tbformail, a.tbforcel, a.tbforcnpj, a.tbforinscmun, a.tbforinscest, a.tbfordata, a.tbforender, a.tbforbairro, a.tbforcep, a.tbforcid, a.tbforest, a.tbfortipo, a.tbforiqfp, a.tbforestagio, a.tbfornatinsp, a.tbforlotesinsp, a.tbforsklotes, a.tbforcompl, a.tbforplano, a.tbforplanoprazo, a.tbforplanoresp, a.tbforflag1, a.tbforflag2, a.tbforcheck1, a.tbforcheck2, a.tbforultnr, a.tbfordatanr, a.tbforlotesatesk, a.tbforvalidade, a.tbforcert, a.tbforiqep, a.tbfornatfor, a.tbforclifor, a.tbforq, a.tbfordataq, a.tbforendercob, a.tbforbairrocob, a.tbforcepcob, a.tbforcidcob, a.tbforestcob, a.tbforenderent, a.tbforbairroent, a.tbforcepent, a.tbforcident, a.tbforestent, a.tbforcpag, a.tbforlimite, a.tbforvlimite, a.tbforbloq, a.tbforesp, a.tbforobscom, a.tbforobsfin, a.tbforcodven, a.tbforregiao, a.tbforsuframa, a.tbforvalsuframa, a.tbformotbloq, a.tbforcodtransp, a.tbfornometransp, a.tbforcompad, a.tbfordepart, a.tbforcfop, a.tbfordesccfop, a.tbforcodant, a.tbcfoi, a.codigo_financeiro, a.codigo_municipio, a.codigo_uf, a.endereco_numero, a.complemento, a.codigo_municipio_ent, a.codigo_uf_ent, a.endereco_numero_ent, a.complemento_ent, a.codigo_municipio_cob, a.codigo_uf_cob, a.endereco_numero_cob, a.complemento_cob, a.codigo_pais, a.produtor_rural, a.fornecedor_st, a.simples_nacional, a.inscrito_municipio, a.conta_contabil
,
b.tbforcnpj, b.tbforraz, b.tbforfan, b.tbforcod
from tbfor2 a left join tbfor b on (a.tbforcnpj = b.tbforcnpj) where f_stringlength(a.tbforcnpj) >=14
;



/* View: MIGRACAO_ITENS */
CREATE VIEW MIGRACAO_ITENS(
    CODIGOITEM,
    NOMEITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    CODFATURAMITEM,
    UNDCOMPRAITEM,
    UNDUSOITEM,
    FATORCONVITEM,
    GRUPOITEM,
    GRUPOCONTAB,
    ICMSITEMVENDA,
    IPIITEMVENDA,
    SITTRIBITEM,
    CLASSFISCALITEM,
    PESOBRITEM,
    PESOLIQITEM,
    PESOESPEITEM,
    COMPRIMITEM,
    LARGURAITEM,
    ESPESSURAITEM,
    ALTURAITEM,
    PRECOVENDA,
    PRECOCOMPRA,
    TABELAICMSITEM,
    ICMSITEMCOMPRA,
    IPIITEMCOMPRA,
    VALORMEDIOITEM,
    VALORCUSTOITEM,
    VALORULTCOMPRA,
    DATAULTCOMPRA,
    VALORULTVENDA,
    DATAULTVENDA,
    MARKUPITEM,
    COMISSAOVENITEM,
    COMISSAOREPITEM,
    COMISSAOINTITEM,
    COMISSAOEXTITEM,
    DESCCOMERCITEM,
    CUSTOMATITEM,
    CUSTOTRATITEM,
    CUSTOPROCITEM,
    CUSTOACABITEM,
    AREAITEM,
    PERIMETROITEM,
    CICLOREPITEM,
    ESTOQUEMINITEM,
    ESTOQUEMAXITEM,
    ESTOQUEPROGITEM,
    ESTOQUECOMPITEM,
    ESTOQUEFISICOITEM,
    ESTOQUEDISPITEM,
    LOCALARMAZITEM,
    RUAARMAZITEM,
    PRATELEIRAITEM,
    INSPECIONAITEM,
    MOVESTOQUE,
    CICLOPRODDITEM,
    ACABAMENTOITEM,
    ESPECIFCAMITEM,
    CAMMINIMAITEM,
    CAMMAXIMAITEM,
    EXIGECAMITEM,
    TIPOITEM,
    CODIGOPAIITEM,
    DESTINOITEM,
    OBSCOMERCITEM,
    OBSTECNICAITEM,
    NOMECLITEM,
    CODCLITEM,
    MENSAGEMPADRAO,
    INCLUSAO,
    DATAREVDES,
    PCSHORA,
    SETUPHS,
    ITEM,
    SEQ,
    ORIGEMITEM,
    CODPROD,
    OPTIPO,
    NATPROD,
    REVPROC,
    DATAREVPROC,
    CNC,
    REVCNC,
    DATAREVCNC,
    ARQUIVO,
    DESCCOMPRA,
    REFITEM,
    DIAMITEM,
    ARVORE,
    REVCUSTO,
    USERCUSTO,
    REFCUSTO,
    ULTFORN,
    ESTOQUESERVITEM,
    ESTOQUEPROCITEM,
    FATORCONVEN,
    UNDVENDA,
    SUBGRUPO,
    COD_ESPECIF,
    IMAGEM,
    ESTOQUEINSP,
    ZERA_SALDO,
    FREQ_REP,
    EMBALAGEMITEM,
    QTD_EMBALAGEM,
    CODIGO_PLASTICOS,
    NOMEITEM_PLASTICOS,
    CLIENTE_PLASTICOS,
    TIPOITEM_PLASTICOS)
AS
select a.codigoitem, a.nomeitem, a.desenhoitem, a.revdesenhoitem, a.codfaturamitem, a.undcompraitem, a.undusoitem,
a.fatorconvitem, a.grupoitem, a.grupocontab, a.icmsitemvenda, a.ipiitemvenda, a.sittribitem, a.classfiscalitem,
a.pesobritem, a.pesoliqitem, a.pesoespeitem, a.comprimitem, a.larguraitem, a.espessuraitem, a.alturaitem, a.precovenda,
a.precocompra, a.tabelaicmsitem, a.icmsitemcompra, a.ipiitemcompra, a.valormedioitem, a.valorcustoitem,
a.valorultcompra, a.dataultcompra, a.valorultvenda, a.dataultvenda, a.markupitem, a.comissaovenitem,
a.comissaorepitem, a.comissaointitem, a.comissaoextitem, a.desccomercitem, a.customatitem, a.custotratitem,
a.custoprocitem, a.custoacabitem, a.areaitem, a.perimetroitem, a.ciclorepitem, a.estoqueminitem, a.estoquemaxitem,
a.estoqueprogitem, a.estoquecompitem, a.estoquefisicoitem, a.estoquedispitem, a.localarmazitem, a.ruaarmazitem,
a.prateleiraitem, a.inspecionaitem, a.movestoque, a.cicloprodditem, a.acabamentoitem, a.especifcamitem,
a.camminimaitem, a.cammaximaitem, a.exigecamitem, a.tipoitem, a.codigopaiitem, a.destinoitem, a.obscomercitem,
a.obstecnicaitem, a.nomeclitem, a.codclitem, a.mensagempadrao, a.inclusao, a.datarevdes, a.pcshora, a.setuphs,
a.item, a.seq, a.origemitem, a.codprod, a.optipo, a.natprod, a.revproc, a.datarevproc, a.cnc, a.revcnc,
a.datarevcnc, a.arquivo, a.desccompra, a.refitem, a.diamitem, a.arvore, a.revcusto, a.usercusto, a.refcusto,
a.ultforn, a.estoqueservitem, a.estoqueprocitem, a.fatorconven, a.undvenda, a.subgrupo, a.cod_especif,
a.imagem, a.estoqueinsp, a.zera_saldo, a.freq_rep, a.embalagemitem, a.qtd_embalagem,
b.codigoitem, b.nomeitem, b.nomeclitem, b.tipoitem
from tbitens2 a left join tbitens b on (a.codigoitem = b.codigoitem)
;



/* View: MOVIMENTO_ADI */
CREATE VIEW MOVIMENTO_ADI(
    PRODUTO,
    DATA,
    DOCTO,
    OS,
    QTD,
    LOTE,
    COD_PARAMETRO,
    NOME_PARAMETRO,
    ORIGEM,
    QTDE,
    MES_LANC)
AS
select codigomat, datalanc, docto, os, qtd_mov, lote, cod_parametro, nome_parametro, 'ADI', -QTD_MOV, mes_lanc from
movimento WHERE MOVIMENTO.datalanc > '01.11.2009' order by datalanc
;



/* View: SAIDA_EMBALAGEM */
CREATE VIEW SAIDA_EMBALAGEM(
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    FANTASIA,
    CODIGOITEM,
    DESCRICAO,
    ENVIO,
    RETORNO,
    UND,
    VLUNIT,
    VLITEM,
    NF_NUMERO)
AS
select
emissao, codcli,NFCFOPI,CFOP,DESCCFOP, fantasia,
codigoitem,DESCRICAO, qtdeitem, 0, und, vlunit, vlitem, tbnf.nf_numero
from tbnf join tbitensnf on (numnf = idnumnf) where cfop in ('5.920','6.920','5.921','6.921')
and canc = 'N' and emissao >='01.01.2010'
order by codcli, codigoitem, emissao
;



/* View: MOVIMENTO_EMBALAGEM */
CREATE VIEW MOVIMENTO_EMBALAGEM(
    DATA,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    FANTASIA,
    CODIGOITEM,
    DESCRICAO,
    ENVIO,
    RETORNO,
    UND,
    VLUNIT,
    VLITEM,
    NF_NUMERO)
AS
select emissao, codcli, nfcfopi, cfop, desccfop, fantasia, codigoitem, descricao, envio, retorno, und, vlunit, vlitem, nf_numero
from saida_embalagem union all
select emissao, codcli, nfcfopi, cfop, desccfop, fantasia, codigoitem, descricao, envio, retorno, und, vlunit, vlitem, nf_numero
from entrada_embalagem

/*-------------------------------------------------------------------------*/
/* Restoring descriptions for views */
/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/
/* Restoring descriptions of view columns */
/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/
/* Restoring privileges */
/*-------------------------------------------------------------------------*/
;



/* View: MOVIMENTO_FATURADO */
CREATE VIEW MOVIMENTO_FATURADO(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    QTDCOMPRA,
    QTDENTRADA,
    QTDINSPECAO,
    QTDSAIDA,
    SETOR,
    SALDOCOMPRA,
    SALDOINSPECAO,
    SALDOFISICO,
    VALORMEDIO,
    VALORLANC,
    HISTORICO,
    UND,
    LOTE,
    SALDORESERV,
    SALDOSERV,
    SALDODISP,
    SALDOPROC,
    QTDERESERV,
    QTDESERV,
    QTDEPROC,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    REQUISICAO,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    VALOR_TOTAL,
    QTD_MOV,
    VALOR_MOV,
    VALOR_MEDIO,
    TIPO_ITEM,
    INVENTARIO,
    LOTE_OS,
    VALOR_INFORMADO,
    OS__ORIGEM)
AS
select idlanc, datasis, datalanc, tblanc.codigomat, idpedido, iditemped, docto, tblanc.os, qtdcompra, qtdentrada, qtdinspecao, qtdsaida, setor, saldocompra, saldoinspecao, saldofisico, valormedio,
case when
tbitens.custoacabitem > 0 then tbitens.custoacabitem 
else valorlanc
end,
historico, und, tblanc.lote, saldoreserv, saldoserv, saldodisp, saldoproc, qtdereserv, qtdeserv, qtdeproc,
tblanc.cod_parametro, tblanc.cfop, tblanc.codfor, tblanc.requisicao, tblanc.nota_fiscal, 
nome_parametro, nomeitem, tb_parametro_movimentacao.grupo, TBLANC.mes_lanc, TBLANC.status, TBLANC.usuario,
TBLANC.hora_lanc,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then TBITENS.custoacabitem * tblanc.qtdsaida
else TBITENS.custoacabitem * tblanc.qtdentrada
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then tblanc.valorlanc * tblanc.qtdsaida
else tblanc.valorlanc * tblanc.qtdentrada
end
end,
case
when tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then 0
when tblanc.qtdentrada <> 0 then tblanc.qtdentrada
when tblanc.qtdsaida <> 0 then (tblanc.qtdsaida * -1)
else 0
end,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (TBITENS.custoacabitem * tblanc.qtdsaida) * -1
when tbitens.custoacabitem > 0 and tblanc.qtdentrada <> 0 then (tbitens.custoacabitem * tblanc.qtdentrada)
else 0
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valorlanc * tblanc.qtdsaida)* -1
when tblanc.valorlanc > 0 and tblanc.qtdentrada <> 0 then (tblanc.valorlanc * tblanc.qtdentrada)
else 0
end
end,
case
when tblanc.valorMEDIO > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valormedio
when tblanc.valormedio > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valormedio * tblanc.qtdsaida)
when tblanc.valormedio > 0 and tblanc.qtdentrada <> 0 then (tblanc.valormedio * tblanc.qtdentrada)
else 0
end,
tbitens.tipoitem, tbtipoitem.inventario,
case
when tbitens.tipoitem = 'PRODUTO ACABADO' THEN TBLANC.os
when tbitens.tipoitem = 'COMPONENTE FABRICADO' THEN TBLANC.OS
when tbitens.tipoitem = 'COMPONENTE COMPRADO' THEN TBLANC.lote 
when tbitens.tipoitem = 'MAT�RIA-PRIMA' THEN TBLANC.LOTE
END,
tbitens.custoacabitem, tblote.os
from tblanc left join tbitens on (codigomat = codigoitem)
left join tb_parametro_movimentacao on (tblanc.cod_parametro = tb_parametro_movimentacao.cod_parametro)
left join tbtipoitem on (tbitens.tipoitem = tbtipoitem.tipoitem)
left join tblote on (tblanc.lote = tblote.lote)
where tblanc.cfop in ('5.101.01','6.101.01','7.101.01') and tblanc.datalanc >='01.01.2013'
;



/* View: SAIDA_MP */
CREATE VIEW SAIDA_MP(
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    FANTASIA,
    CODIGOITEM,
    DESCRICAO,
    QTDE,
    UND,
    VLUNIT,
    VLITEM,
    NF_NUMERO,
    NOSSA_NF)
AS
select
emissao, codcli,NFCFOPI,'S',DESCCFOP, fantasia,
codigoitem,DESCRICAO, (qtdeitem * -1), und, vlunit, vlitem, tbitensnf.nf_referencia,  tbnf.nf_numero
from tbnf join tbitensnf on (numnf = idnumnf) where cfop in ('5.902','6.902')
and canc = 'N' and emissao >='01.01.2013'
order by codcli, codigoitem, emissao
;



/* View: MOVIMENTO_MP */
CREATE VIEW MOVIMENTO_MP(
    DATA,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    FANTASIA,
    CODIGOITEM,
    DESCRICAO,
    QTDE,
    UND,
    VLUNIT,
    VLITEM,
    NF_NUMERO,
    NOSSA_NF)
AS
select emissao, codcli, nfcfopi, cfop, desccfop, fantasia, codigoitem, descricao, QTDE, und, vlunit, vlitem, nf_numero, nossa_nf
from entrada_mp union all
select emissao, codcli, nfcfopi, cfop, desccfop, fantasia, codigoitem, descricao, QTDE, und, vlunit, vlitem, nf_numero, nossa_nf
from saida_mp

/*-------------------------------------------------------------------------*/
/* Restoring descriptions for views */
/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/
/* Restoring descriptions of view columns */
/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/
/* Restoring privileges */
/*-------------------------------------------------------------------------*/
;



/* View: MOVIMENTO_PROC */
CREATE VIEW MOVIMENTO_PROC(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    QTDCOMPRA,
    QTDENTRADA,
    QTDINSPECAO,
    QTDSAIDA,
    SETOR,
    SALDOCOMPRA,
    SALDOINSPECAO,
    SALDOFISICO,
    VALORMEDIO,
    VALORLANC,
    HISTORICO,
    UND,
    LOTE,
    SALDORESERV,
    SALDOSERV,
    SALDODISP,
    SALDOPROC,
    QTDERESERV,
    QTDESERV,
    QTDEPROC,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    REQUISICAO,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    VALOR_TOTAL,
    QTD_MOV,
    VALOR_MOV,
    VALOR_MEDIO,
    TIPO_ITEM,
    TEMPO_UNIT,
    TEMPO_TOTAL,
    CUSTO_UNIT,
    CUSTO_TOTAL,
    COMPONENTE,
    SEQ,
    IDPROC,
    SETUP,
    TIPO,
    QTD_OS)
AS
select idlanc, datasis, datalanc, codigomat, idpedido, iditemped, docto, os, qtdcompra, qtdentrada, qtdinspecao, qtdsaida, setor, saldocompra, saldoinspecao, saldofisico, valormedio, valorlanc, historico, und, lote, saldoreserv, saldoserv, saldodisp, saldoproc, qtdereserv, qtdeserv, qtdeproc,
TBLANC_PROC.cod_parametro, TBLANC_PROC.cfop, TBLANC_PROC.codfor, TBLANC_PROC.requisicao, TBLANC_PROC.nota_fiscal, 
nome_parametro, nomeitem, tb_parametro_movimentacao.grupo, TBLANC_PROC.mes_lanc, TBLANC_PROC.status, TBLANC_PROC.usuario,
TBLANC_PROC.hora_lanc,
case
when TBLANC_PROC.valorlanc > 0 and TBLANC_PROC.qtdentrada = 0 and TBLANC_PROC.qtdsaida = 0 then TBLANC_PROC.valorlanc
when TBLANC_PROC.valorlanc > 0 and TBLANC_PROC.qtdentrada = 0 and TBLANC_PROC.qtdsaida > 0 then TBLANC_PROC.valorlanc * TBLANC_PROC.qtdsaida
else TBLANC_PROC.valorlanc * TBLANC_PROC.qtdentrada
end,
case
when TBLANC_PROC.qtdentrada = 0 and TBLANC_PROC.qtdsaida = 0 then 0
when TBLANC_PROC.qtdentrada > 0 then TBLANC_PROC.qtdentrada * -1
when TBLANC_PROC.qtdsaida > 0 then (TBLANC_PROC.qtdsaida)
else 0
end,
case
when TBLANC_PROC.valorlanc > 0 and TBLANC_PROC.qtdentrada = 0 and TBLANC_PROC.qtdsaida = 0 then TBLANC_PROC.valorlanc
when TBLANC_PROC.valorlanc > 0 and TBLANC_PROC.qtdentrada = 0 and TBLANC_PROC.qtdsaida > 0 then (TBLANC_PROC.valorlanc * TBLANC_PROC.qtdsaida)
when TBLANC_PROC.valorlanc > 0 and TBLANC_PROC.qtdentrada > 0 then (TBLANC_PROC.valorlanc * TBLANC_PROC.qtdentrada)* -1
else 0
end,
case
when TBLANC_PROC.valorMEDIO > 0 and TBLANC_PROC.qtdentrada = 0 and TBLANC_PROC.qtdsaida = 0 then TBLANC_PROC.valormedio
when TBLANC_PROC.valormedio > 0 and TBLANC_PROC.qtdentrada = 0 and TBLANC_PROC.qtdsaida > 0 then (TBLANC_PROC.valormedio * TBLANC_PROC.qtdsaida)
when TBLANC_PROC.valormedio > 0 and TBLANC_PROC.qtdentrada > 0 then (TBLANC_PROC.valormedio * TBLANC_PROC.qtdentrada) * -1
else 0
end,
tbitens.tipoitem, tempo_unit, tempo_total, custo_unit, custo_total, componente, TBLANC_PROC.seq, idproc, setup, tipo,
qtd_os
from TBLANC_PROC left join tbitens on (codigomat = codigoitem)
left join tb_parametro_movimentacao on (TBLANC_PROC.cod_parametro = tb_parametro_movimentacao.cod_parametro)
;



/* View: MOVIMENTO_REMESSA */
CREATE VIEW MOVIMENTO_REMESSA(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    HISTORICO,
    UND,
    LOTE,
    QTDESERV,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    QTD_MOV,
    TIPO_ITEM,
    INVENTARIO,
    NOTA_REMESSA,
    CANC)
AS
select idlanc, datasis, datalanc, codigomat, idpedido, iditemped, docto, os,  historico, und, lote, qtdeserv,
tblanc.cod_parametro, tblanc.cfop, tblanc.codfor, tblanc.nota_fiscal,
nome_parametro, nomeitem, tb_parametro_movimentacao.grupo, TBLANC.mes_lanc, TBLANC.status, TBLANC.usuario,
TBLANC.hora_lanc, TBLANC.qtdeserv,
tbitens.tipoitem, tbtipoitem.inventario, NOTA_FISCAL, TBNF.canc 
from tblanc left join tbitens on (codigomat = codigoitem)
LEFT JOIN tbnf ON (CAST(TBLANC.nota_fiscal AS NUMERIC(15,0)) = TBNF.nf_numero)
left join tb_parametro_movimentacao on (tblanc.cod_parametro = tb_parametro_movimentacao.cod_parametro)
left join tbtipoitem on (tbitens.tipoitem = tbtipoitem.tipoitem)
where tblanc.cod_parametro in ('04.07') AND TBLANC.datalanc >= '01.08.2011'  AND TBNF.canc = 'N'
AND tbtipoitem.inventario = 1
;



/* View: MOVIMENTO_RESERVA_OS */
CREATE VIEW MOVIMENTO_RESERVA_OS(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    QTDCOMPRA,
    QTDENTRADA,
    QTDINSPECAO,
    QTDSAIDA,
    SETOR,
    SALDOCOMPRA,
    SALDOINSPECAO,
    SALDOFISICO,
    VALORMEDIO,
    VALORLANC,
    HISTORICO,
    UND,
    LOTE,
    SALDORESERV,
    SALDOSERV,
    SALDODISP,
    SALDOPROC,
    QTDERESERV,
    QTDESERV,
    QTDEPROC,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    REQUISICAO,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    VALOR_TOTAL,
    QTD_MOV,
    VALOR_MOV,
    VALOR_MEDIO,
    TIPO_ITEM,
    INVENTARIO,
    LOTE_OS,
    VALOR_INFORMADO,
    OS__ORIGEM)
AS
select idlanc, datasis, datalanc, tblanc.codigomat, idpedido, iditemped, docto, tblanc.os, qtdcompra, qtdentrada, qtdinspecao, qtdsaida, setor, saldocompra, saldoinspecao, saldofisico, valormedio,
case when
tbitens.custoacabitem > 0 then tbitens.custoacabitem 
else valorlanc
end,
historico, und, tblanc.lote, saldoreserv, saldoserv, saldodisp, saldoproc, qtdereserv, qtdeserv, qtdeproc,
tblanc.cod_parametro, tblanc.cfop, tblanc.codfor, tblanc.requisicao, tblanc.nota_fiscal, 
nome_parametro, nomeitem, tb_parametro_movimentacao.grupo, TBLANC.mes_lanc, TBLANC.status, TBLANC.usuario,
TBLANC.hora_lanc,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then TBITENS.custoacabitem * tblanc.qtdsaida
else TBITENS.custoacabitem * tblanc.qtdentrada
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida > 0 then tblanc.valorlanc * tblanc.qtdsaida
else tblanc.valorlanc * tblanc.qtdentrada
end
end,
case
when tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then 0
when tblanc.qtdentrada <> 0 then tblanc.qtdentrada
when tblanc.qtdsaida <> 0 then (tblanc.qtdsaida * -1)
else 0
end,
CASE WHEN TBITENS.custoacabitem > 0 then
case
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then TBITENS.custoacabitem
when TBITENS.custoacabitem > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (TBITENS.custoacabitem * tblanc.qtdsaida) * -1
when tbitens.custoacabitem > 0 and tblanc.qtdentrada <> 0 then (tbitens.custoacabitem * tblanc.qtdentrada)
else 0
end
else
case
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valorlanc
when tblanc.valorlanc > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valorlanc * tblanc.qtdsaida)* -1
when tblanc.valorlanc > 0 and tblanc.qtdentrada <> 0 then (tblanc.valorlanc * tblanc.qtdentrada)
else 0
end
end,
case
when tblanc.valorMEDIO > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida = 0 then tblanc.valormedio
when tblanc.valormedio > 0 and tblanc.qtdentrada = 0 and tblanc.qtdsaida <> 0 then (tblanc.valormedio * tblanc.qtdsaida)
when tblanc.valormedio > 0 and tblanc.qtdentrada <> 0 then (tblanc.valormedio * tblanc.qtdentrada)
else 0
end,
tbitens.tipoitem, tbtipoitem.inventario,
case
when tbitens.tipoitem = 'PRODUTO ACABADO' THEN TBLANC.os
when tbitens.tipoitem = 'COMPONENTE FABRICADO' THEN TBLANC.OS
when tbitens.tipoitem = 'COMPONENTE COMPRADO' THEN TBLANC.lote 
when tbitens.tipoitem = 'MAT�RIA-PRIMA' THEN TBLANC.LOTE
END,
tbitens.custoacabitem, tblote.os
from tblanc left join tbitens on (codigomat = codigoitem)
left join tb_parametro_movimentacao on (tblanc.cod_parametro = tb_parametro_movimentacao.cod_parametro)
left join tbtipoitem on (tbitens.tipoitem = tbtipoitem.tipoitem)
left join tblote on (tblanc.lote = tblote.lote)
where tbitens.tipoitem IN ('MAT�RIA-PRIMA','COMPONENTE COMPRADO') AND TBLANC.cod_parametro = '03.10'
;



/* View: MOVIMENTO_RETORNO */
CREATE VIEW MOVIMENTO_RETORNO(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    HISTORICO,
    UND,
    LOTE,
    QTDESERV,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    QTD_MOV,
    TIPO_ITEM,
    INVENTARIO,
    NOTA_REMESSA,
    QTD_NOTA,
    UND_NOTA)
AS
select distinct idlanc, datasis, datalanc, codigomat, TBLANC.idpedido, TBLANC.iditemped, docto, os,  historico, TBLANC.und, lote, qtdeserv,
tblanc.cod_parametro, tblanc.cfop, tblanc.codfor, tblanc.nota_fiscal,
nome_parametro, nomeitem, tb_parametro_movimentacao.grupo, TBLANC.mes_lanc, TBLANC.status, TBLANC.usuario,
TBLANC.hora_lanc, TBLANC.qtdeserv * -1,
tbitens.tipoitem, tbtipoitem.inventario, notasfiscaisc.nfsaida , notasfiscaisc.qtdeitem , notasfiscaisc.und 
from tblanc left join tbitens on (codigomat = codigoitem)
LEFT JOIN notasfiscaisc ON (TBLANC.nota_fiscal = notasfiscaisc.pedidocli and tblanc.codigomat = notasfiscaisc.codigoitem)
left join tb_parametro_movimentacao on (tblanc.cod_parametro = tb_parametro_movimentacao.cod_parametro)
left join tbtipoitem on (tbitens.tipoitem = tbtipoitem.tipoitem)
where tblanc.cod_parametro in ('01.10') AND TBLANC.datalanc >= '19.09.2011'
;



/* View: MOVIMENTO_TERCEIRO */
CREATE VIEW MOVIMENTO_TERCEIRO(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    HISTORICO,
    UND,
    LOTE,
    QTDESERV,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    QTD_MOV,
    TIPO_ITEM,
    INVENTARIO,
    NOTA_REMESSA)
AS
select idlanc, datasis, datalanc, codigomat, idpedido, iditemped, docto, os, historico, und, lote, qtdeserv, cod_parametro, cfop, codfor, nota_fiscal, nome_parametro, nomeitem, grupo, mes_lanc, status, usuario, hora_lanc, qtd_mov, tipo_item, inventario, nota_remessa
from movimento_remessa UNION ALL
select idlanc, datasis, datalanc, codigomat, idpedido, iditemped, docto, os, historico, und, lote, qtdeserv, cod_parametro, cfop, codfor, nota_fiscal, nome_parametro, nomeitem, grupo, mes_lanc, status, usuario, hora_lanc, qtd_mov, tipo_item, inventario, nota_remessa
from movimento_RETORNO
;



/* View: SALDO_MOVIMENTO_TERCEIRO */
CREATE VIEW SALDO_MOVIMENTO_TERCEIRO(
    CODIGOMAT,
    CODFOR,
    NOTA_REMESSA,
    SALDO)
AS
select codigomat, codfor, nota_remessa, SUM(qtd_mov)
from movimento_remessa
GROUP BY  codigomat, codfor, nota_remessa
;



/* View: MOVIMENTO_TERCEIRO_ATUAL */
CREATE VIEW MOVIMENTO_TERCEIRO_ATUAL(
    IDLANC,
    DATASIS,
    DATALANC,
    CODIGOMAT,
    IDPEDIDO,
    IDITEMPED,
    DOCTO,
    OS,
    HISTORICO,
    UND,
    LOTE,
    QTDESERV,
    COD_PARAMETRO,
    CFOP,
    CODFOR,
    NOTA_FISCAL,
    NOME_PARAMETRO,
    NOMEITEM,
    GRUPO,
    MES_LANC,
    STATUS,
    USUARIO,
    HORA_LANC,
    QTD_MOV,
    TIPO_ITEM,
    INVENTARIO,
    NOTA_REMESSA,
    SALDO)
AS
select idlanc, datasis, datalanc, movimento_terceiro.codigomat, idpedido, iditemped, docto, os, historico, und, lote, qtdeserv, cod_parametro, cfop, movimento_terceiro.codfor, nota_fiscal, nome_parametro, nomeitem, grupo, mes_lanc, status, usuario, hora_lanc, qtd_mov, tipo_item, inventario, movimento_terceiro.nota_remessa,
saldo_movimento_terceiro.saldo 
from movimento_terceiro LEFT JOIN saldo_movimento_terceiro ON (movimento_terceiro.codfor = saldo_movimento_terceiro.codfor 
AND movimento_terceiro.nota_remessa = saldo_movimento_terceiro.nota_remessa AND movimento_terceiro.codigomat = saldo_movimento_terceiro.codigomat)
order by movimento_terceiro.codfor , movimento_terceiro.nota_remessa, movimento_terceiro.codigomat, movimento_terceiro.qtd_mov DESC,  movimento_terceiro.datalanc
;



/* View: MP_BRUTO_MES_ANO_FOR */
CREATE VIEW MP_BRUTO_MES_ANO_FOR(
    NOME,
    MES,
    MESNUM,
    ANO,
    TOTAL,
    FORNECEDOR)
AS
select A.nomevend, a.mes, A.mesnum, a.ano,
sum(a.vlitem), a.fantasia from nfc a where a.ano = 2015
group by A.nomevend, mes, mesnum, ano, a.fantasia order by a.ano, a.mesnum
;



/* View: NAO_CONSTA_CPAG */
CREATE VIEW NAO_CONSTA_CPAG(
    NUMPED,
    CONDICAO1,
    CONDICAO2)
AS
select tbpropc.numped, tbpropc.cpag,  tbcpag.cpag from tbpropc left join tbcpag
on (tbpropc.cpag = tbcpag.cpag) where tbcpag.cpag is null
;



/* View: NEGOCIA */
CREATE VIEW NEGOCIA(
    IDNEG,
    CODITEM,
    NUMPED,
    DATA,
    STATUSNEG,
    PRECOANT,
    PRECOATUAL,
    DESCONTO,
    QTDENEG,
    HISTORICO,
    GRAVADOPOR,
    DATAGRAV,
    REAJUSTE,
    IDITEM,
    FANTASIA)
AS
select idneg, coditem, tbnegocia.numped, data, statusneg, precoant, precoatual, desconto, qtdeneg, historico, gravadopor, datagrav, reajuste, iditem, fantasia from
tbnegocia join tbprop on (tbnegocia.numped = tbprop.numped)
;



/* View: NF */
CREATE VIEW NF(
    NUMNF,
    EMISSAO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    PEDIDOCLI,
    QTDEITEM,
    VLUNIT,
    VLITEM,
    DESENHO,
    NUMPED,
    NF_NUMERO,
    UNIDADE)
AS
select
numnf, emissao, codcli, razao, fantasia, tipo, canc, vend, nomevend,
iditemnf, iditemped, codigoitem, tbitensnf.pedidocli, qtdeitem, vlunit, vlitem, desenho, numped, nf_numero, unidade
from tbnf join tbitensnf on (idnumnf = numnf)
where status > 0
;



/* View: NF_EMITIDAS */
CREATE VIEW NF_EMITIDAS(
    CODCLI,
    RAZAO)
AS
select codcli, razao from tbnf
group by codcli, razao
;



/* View: NF_FAT */
CREATE VIEW NF_FAT(
    NUMNF,
    SISTEMA,
    EMISSAO,
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    CFOP,
    NFCFOPI,
    DESCCFOP,
    VALORICMS,
    VALORIPI,
    VALORITENS,
    VALORTOTALNF,
    UNIDADE)
AS
select
numnf, sistema, emissao, f_dayofmonth(emissao), f_cdowSHORTlang(emissao,'PT') , f_padleft(f_month(emissao),'0',2) || '/' || f_year(EMISSAO) , codcli, razao, fantasia, tipo, canc, vend, nomevend, stacom, tbnf.status,
cfop,nfcfopi, desccfop, valoricms, valoripi, valoritens, valortotalnf, tbnf.unidade 
from tbnf WHERE (DESCCFOP LIKE 'VENDA%') and (status > 0) and (canc = 'N')
;



/* View: NF_FAT_POR_PROD */
CREATE VIEW NF_FAT_POR_PROD(
    NUMNF,
    SISTEMA,
    EMISSAO,
    DIA,
    DIA_SEM,
    MES_ANO,
    CODCLI,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    VEND,
    NOMEVEND,
    STACOM,
    STATUS,
    CFOP,
    NFCFOPI,
    DESCCFOP,
    VALORICMS,
    VALORIPI,
    VALORITENS,
    VALORTOTALNF,
    UNIDADE,
    PRODUTO,
    QTDE,
    UNITARIO,
    TOTAL,
    DD,
    MM,
    AA,
    SEM,
    DESENHOITEM)
AS
select
numnf, sistema, emissao, f_dayofmonth(emissao), f_cdowSHORTlang(emissao,'PT') , f_padleft(f_month(emissao),'0',2) || '/' || f_year(EMISSAO) , codcli, tbfor.tbforraz, tbfor.tbforfan , tipo, canc, vend, nomevend, stacom, tbnf.status,
cfop,nfcfopi, desccfop, valoricms, valoripi, valoritens, valortotalnf, tbnf.unidade,
TBITENSNF.codigoitem, TBITENSNF.qtdeitem, TBITENSNF.vlunit, TBITENSNF.vlitem, f_padleft(f_dayofmonth(EMISSAO),'0',2),
f_padleft(f_month(EMISSAO),'0',2), f_RIGHT(f_year(EMISSAO),2), f_padleft(f_weekofyear(EMISSAO),'0',2), tbitensnf.desenho 
from tbnf LEFT JOIN TBITENSNF ON (TBNF.numnf = TBITENSNF.idnumnf) left join tbfor on (tbnf.codcli = tbfor.tbforcod)  WHERE (STACOM in(0,4)) and (canc = 'N') and (tipo = 'S')
;



/* View: NOTANET */
CREATE VIEW NOTANET(
    CODCLI,
    FANTASIA,
    RAZAO,
    FONE,
    CNPJ,
    INSC_ESTADUAL,
    ENDERECO_CLI,
    BAIRRO_CLI,
    CEP_CLI,
    MUNICIPIO_CLI,
    UF_CLI,
    END_NUMERO,
    COMPLEMENTO,
    MAIL,
    CONTATO)
AS
select tbnf.codcli, tbfor.tbforfan, tbfor.tbforraz, tbfor.tbforfone,
tbfor.tbforcnpj, tbfor.tbforinscest, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest,
tbfor.endereco_numero, tbfor.complemento, tbfor.tbformail,  tbfor.tbforcont  from tbnf left join tbfor on (tbnf.codcli = tbfor.tbforcod)
group by tbnf.codcli, tbfor.tbforfan, tbfor.tbforraz, tbfor.tbforfone,
tbfor.tbforcnpj, tbfor.tbforinscest, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest,
tbfor.endereco_numero, tbfor.complemento, tbfor.tbformail,  tbfor.tbforcont
;



/* View: NOTAS_ALL */
CREATE VIEW NOTAS_ALL(
    CODCLI,
    FANTASIA,
    RAZAO,
    FONE,
    CNPJ,
    INSC_ESTADUAL,
    ENDERECO_CLI,
    BAIRRO_CLI,
    CEP_CLI,
    MUNICIPIO_CLI,
    UF_CLI,
    END_NUMERO,
    COMPELEMNTO)
AS
select tbnf.codcli, tbfor.tbforfan, tbfor.tbforraz, tbfor.tbforfone,
tbfor.tbforcnpj, tbfor.tbforinscest, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest,
tbfor.endereco_numero, tbfor.complemento from tbnf left join tbfor on (tbnf.codcli = tbfor.tbforcod)
group by tbnf.codcli, tbfor.tbforfan, tbfor.tbforraz, tbfor.tbforfone,
tbfor.tbforcnpj, tbfor.tbforinscest, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest,
tbfor.endereco_numero, tbfor.complemento
;



/* View: NOTAS_CERTIFICADO */
CREATE VIEW NOTAS_CERTIFICADO(
    NUMNF,
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    TIPO,
    CANC,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    DESENHO,
    NUMPED,
    STACOM,
    COMPLEM,
    EMI_CERT,
    OS1,
    OS2,
    OS3,
    OS4,
    QTD1,
    QTD2,
    QTD3,
    QTD4,
    NF_NUMERO)
AS
select
numnf, emissao, codcli,NFCFOPI,CFOP,DESCCFOP, razao, fantasia,TIPO,canc,
iditemnf, iditemped, tbitensnf.codigoitem,DESCRICAO, tbitensnf.pedidocli, qtdeitem,und, desenho, tbitensnf.numped, STACOM, textolegal, tbitens.markupitem,
tbitensnf.n_os, n_os2, n_os3, n_os4, tbitensnf.qt_os, qt_os2,qt_os3,qt_os4
,nf_numero
from tbnf join tbitensnf join tbitens on (tbitensnf.codigoitem = tbitens.codigoitem)  on (idnumnf = numnf)
where tbitens.markupitem = 1 and tbnf.cfop in ('5.101','6.101','7.101','5.917','6.917') and tbnf.canc = 'N' and tbnf.tipo = 'S'
;



/* View: NOTAS_EMBALAGEM */
CREATE VIEW NOTAS_EMBALAGEM(
    NUMNF,
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    VALORICMS,
    VALORIPI,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    VLITEMIPI,
    IPI,
    ICMS,
    DESENHO,
    NUMPED,
    FCONV,
    STACOM,
    COMPLEM,
    NOTA)
AS
select
numnf, emissao, codcli,NFCFOPI,CFOP,DESCCFOP, razao, fantasia,VALORTOTALNF,TBNF.valoricms, TBNF.valoripi, tipo, canc, vend, TBNF.status, NOMEVEND,
iditemnf, iditemped, codigoitem,DESCRICAO, tbitensnf.pedidocli, qtdeitem,und, vlunit, vlitem,tbitensnf.vlipi,IPI,TBNF.icms ,  desenho, numped, FCONV, STACOM, tbitensnf.textolegal, tipos_saidas.nota 
from tbnf join tipos_saidas join tbitensnf on(tbnf.stacom = tipos_saidas.id) on (idnumnf = numnf) where cfop in ('5.920','6.920')
;



/* View: NOTAS_ENTRADA_EXP */
CREATE VIEW NOTAS_ENTRADA_EXP(
    NOTA,
    LINHA,
    FILIAL,
    CNPJ_FILIAL,
    CNPJCLI,
    NFCFOPI,
    NUMNF_INICIO,
    NUMNF_FIM,
    MODELO,
    ESPECIE,
    SERIE,
    SISTEMA,
    EMISSAO,
    UF_DESTINO,
    UF_ORIGEM,
    COD_FISCAL_MUN,
    IND_BASE_RED,
    IND_CONTRIB,
    CANC,
    IND_PAG,
    TIPOFRETE,
    OBS_NF,
    ICMS,
    VALORTOTALNF,
    BASEICMS,
    VALORICMS,
    ISENTA_ICMS,
    OUTROS_ICMS,
    IPI_EMBUT,
    VAL_AC_FIN,
    VAL_DESC,
    BASE_CALC_1_IMP,
    VAL_1_IMP,
    BASE_CALC_2_IMP,
    VAL_2_IMP,
    BASEIPI,
    VALORIPI,
    ISENTAS_IPI,
    OUTROS_IPI,
    REDUCAO_IPI,
    HISTORICO_CONTABIL_CREDITO,
    HISTORICO_CONTABIL_DEBITO,
    PIS_VALOR,
    COFINS_VALOR,
    CHAVE_ACESSO,
    ALIQICMS,
    ALIQIPI)
AS
select
numnf,
'"1"' as linha,
'"'||tbnfc.unidade||'"' as filial,
'"'||tbempresa.cnpj||'"' as cnpj_filial,
case when f_stringlength(cnpjcli)<14 then
    case when tbfor.tbforcodant > 0 then
    '"'||tbfor.tbforcodant||'"'
    else
    '"'||'F'||tbfor.tbforcod||'"'
    end
else
'"'||cnpjcli||'"'
end,
'"'||tbnfc.nfcfopi||'"',
'"'||pedidocli||'"',
'"'||pedidocli||'"',
'"'||tbnfc.modelo||'"',
case when tbnfc.tipo_doc 
like 'NFE%' and tbnfc.modelo = '55' then '"NFE"'
when tbnfc.tipo_doc 
like 'NFE%' and tbnfc.modelo = '57' then '"CTE"'
when tbnfc.tipo_doc
like 'NF_FRETE' then '"CTR"'
else '"NF"'
end,
'"'||tbnfc.serie||'"',
'"'|| f_padleft (f_dayofmonth (sistema),'0',2) ||'/' || f_padleft(f_month(sistema),'0',2)||'/'||f_year(sistema)||'"',
'"'|| f_padleft (f_dayofmonth(emissao),'0',2) ||'/' || f_padleft(f_month(emissao),'0',2)||'/'||f_year(emissao)||'"',
'"SP"' AS uf_destino,
'"'||tbfor.tbforest||'"' AS uf_origem,
'"0"' AS cod_fiscal_mun,
'"N"' AS ind_base_red,
'"S"' AS ind_contrib,
'"'||canc||'"',
case (CPAG)
when 'A VISTA' then '"V"'
ELSE '"P"'
end,
case (tipotransp)
when 1 then '"F"' else '"C"'
end,
'" "' AS obs_nf,

case
when aliqicms in (0,3) then
'"'||icms||'"'
else
'"0.00"'
end
,
'"'||valortotalnf||'"',
/* base icms */
case when
aliqicms in (0,3) then
'"'||baseicms||'"'
else
'"0.00"'
end
,
/* valor icms */
case when aliqicms in (0,3) then
'"'||valoricms||'"'
else
'"0.00"'
end,
/* valor isentas */
case when aliqicms = 2 then
case when valoricms = 0 then
'"'||tbnfc.valortotalnf||'"'
else
'"'||valoricms||'"'
end
else
'"0.00"'
end  as isenta_icms,
/* valor outros */
case when aliqicms = 1 then
case when valoricms = 0 then
'"'||tbnfc.valortotalnf||'"'
else
'"'||valoricms||'"'
end
when aliqicms = 3 then
case when valoricms = 0 then
'"'||tbnfc.valortotalnf||'"'
else
'"'||(valoritens - baseicms)||'"'
end
else
'"0.00"'
end as outros_icms,
case when aliqipi = 0 then
'"'||valoripi||'"'
else
'"0.00"'
end as ipi_embut,
'"0.00"' as val_ac_fin,
'"0.00"' as val_desc,
'"0.00"' as base_calc_1_imp,
'"0.00"' as val_1_imp,
'"0.00"' as base_calc_2_imp,
'"0.00"' as val_2_imp,
case when aliqipi = 0 then
'"'||tbnfc.valoritens||'"'
else
'"0.00"'
end as baseipi,

case when aliqipi = 0 then
'"'||valoripi||'"'
else
'"0.00"'
end,

case when aliqipi = 2 then

case when valoripi = 0 then

'"'||tbnfc.valortotalnf||'"'
else
'"'||valoripi||'"'
end


else
'"0.00"'
end as isentas_ipi,

case when aliqipi = 1 then
case when valoripi = 0 then
'"'||tbnfc.valortotalnf||'"'
else
'"'||valoripi||'"'
end
else
'"0.00"'
end as outros_ipi,
'"0.00"' as reducao_ipi,
'"ENTRD;'||
tbnfc.nfcfopi 
||';'||
case
WHEN TBNFC.nossoped IS NULL THEN '000000'
ELSE f_padleft(TBNFC.nossoped,'0',6)
end ||';'||
case 
WHEN TBNFC.pedidocli IS NULL THEN '000000'
ELSE f_padleft(TBNFC.pedidocli,'0',6)
END
||';'||
CASE
WHEN TBNFC.cnpjcli is NULL THEN tbnfc.codcli 
ELSE TBNFC.cnpjcli
END
||';'||
CASE
WHEN TBNFC.fantasia is NULL THEN ''
ELSE TBNFC.fantasia 
END
||';'||
case when tbnfc.tipo_doc is null then ';'
else
tbnfc.tipo_doc end
||'"',
'"ENTRD;'||
tbnfc.nfcfopi 
||';'||
case
WHEN TBNFC.nossoped IS NULL THEN '000000'
ELSE f_padleft(TBNFC.nossoped,'0',6)
end ||';'||
case 
WHEN TBNFC.pedidocli IS NULL THEN '000000'
ELSE f_padleft(TBNFC.pedidocli,'0',6)
END
||';'||
CASE
WHEN TBNFC.cnpjcli is NULL THEN tbnfc.codcli 
ELSE TBNFC.cnpjcli
END
||';'||
CASE
WHEN TBNFC.fantasia is NULL THEN ''
ELSE TBNFC.fantasia 
END
||';'||
case when tbnfc.tipo_doc is null then ';'
else
tbnfc.tipo_doc end
||'"',
'"0.00"' as pis_valor,
'"0.00"' as cofins_valor,
case when tbnfc.chave_acesso is not null
then
'"'||tbnfc.chave_acesso||'"'
else '""'
end, 
ALIQICMS, ALIQIPI
from tbnfc left join tbcfop on (tbnfc.nfcfopi = tbcfop.cfopi)
left join tbempresa on (tbnfc.unidade = tbempresa.id)
left join tbfor on (tbnfc.codcli = tbfor.tbforcod)
WHERE emissao is not null order by pedidocli, cnpjcli, nfcfopi
;



/* View: NOTAS_ENTRADA_EXP_NEW */
CREATE VIEW NOTAS_ENTRADA_EXP_NEW(
    NOTA,
    LINHA,
    FILIAL,
    CNPJ_FILIAL,
    CNPJCLI,
    NFCFOPI,
    NUMNF_INICIO,
    NUMNF_FIM,
    MODELO,
    ESPECIE,
    SERIE,
    SISTEMA,
    EMISSAO,
    UF_DESTINO,
    UF_ORIGEM,
    COD_FISCAL_MUN,
    IND_BASE_RED,
    IND_CONTRIB,
    CANC,
    IND_PAG,
    TIPOFRETE,
    OBS_NF,
    ICMS,
    VALORTOTALNF,
    BASEICMS,
    VALORICMS,
    ISENTA_ICMS,
    OUTROS_ICMS,
    IPI_EMBUT,
    VAL_AC_FIN,
    VAL_DESC,
    BASE_CALC_1_IMP,
    VAL_1_IMP,
    BASE_CALC_2_IMP,
    VAL_2_IMP,
    BASEIPI,
    VALORIPI,
    ISENTAS_IPI,
    OUTROS_IPI,
    REDUCAO_IPI,
    FORM_NUM,
    IND_RETENCAO,
    DATA_RETENCAO,
    DATA_VENC,
    CONTA_DEBITO,
    HIST_DEBITO,
    CONTA_CREDITO,
    HIST_CREDITO,
    CONTA_DESC_CREDITO,
    CONTA_DESC_DEBITO,
    NUMNF,
    REG_SISCOMEX,
    DESP_SISCOMEX,
    EMB_SICOMEX,
    VAL_SISCOMEX,
    COD_MOEDA_SISCOMEX,
    COD_PAIS_SISCOMEX,
    REDESPACHO,
    VALORFRETE,
    VALORSEGURO,
    OUTRASDEPESAS,
    VALORISS,
    VAL_COMPRA,
    NF_PROPRIA,
    SEM_EFEITO,
    TBFORCODTRANSP,
    VIA_TRANSP,
    QTDEVOL,
    VOLUME,
    PESOBRUTO,
    PESOLIQ,
    IDENTIFICACAO,
    UFPLACATRANSP,
    IDENTIFICACAO2,
    UF_VEIC2,
    IDENTIFICACAO3,
    UF_VEIC3,
    DI_NUM,
    PIS_VALOR,
    COFINS_VALOR,
    BC_ICMS,
    ICMS_ANTECIP,
    ICMS_ANTECIP_PAGO,
    FUNDAP,
    COD_ANTECIP,
    TIPO_RECEITA,
    ALIQICMS,
    ALIQIPI)
AS
select
numnf,
'"1"' as linha,
'"'||tbnfc.unidade||'"' as filial,
'"'||tbempresa.cnpj||'"' as cnpj_filial,
'"'||cnpjcli||'"',
'"'||tbnfc.nfcfopi||'"',
'"'||pedidocli||'"',
'"'||pedidocli||'"',
'"1"' as modelo,
'"NF"' as especie,
'"1"' as serie,
'"'|| f_padleft (f_dayofmonth (sistema),'0',2) ||'/' || f_padleft(f_month(sistema),'0',2)||'/'||f_year(sistema)||'"',
'"'|| f_padleft (f_dayofmonth(emissao),'0',2) ||'/' || f_padleft(f_month(emissao),'0',2)||'/'||f_year(emissao)||'"',
'"SP"' AS uf_destino,
'"'||tbforest||'"' AS uf_origem,
'"0"' AS cod_fiscal_mun,
'"N"' AS ind_base_red,
'"S"' AS ind_contrib,
'"'||canc||'"',
case (CPAG)
when 'A VISTA' then '"V"'
ELSE '"P"'
end,
case (tipotransp)
when 1 then '"F"' else '"C"'
end,
'" "' AS obs_nf,

case
when aliqicms = 0 then
'"'||icms||'"'
else
'"0.00"'
end
,
'"'||valortotalnf||'"',
case when
aliqicms = 0 then

'"'||baseicms||'"'
else
'"0.00"'
end
,
case when aliqicms = 0 then
'"'||valoricms||'"'
else
'"0.00"'
end,
case when aliqicms = 2 then 
'"'||valoricms||'"'
else
'"0.00"'
end  as isenta_icms,
case when aliqicms = 1 then
'"'||valoricms||'"'
else
'"0.00"'
end as outros_icms,
case when aliqipi = 0 then
'"'||valoripi||'"'
else
'"0.00"'
end as ipi_embut,
'"0.00"' as val_ac_fin,
'"0.00"' as val_desc,
'"0.00"' as base_calc_1_imp,
'"0.00"' as val_1_imp,
'"0.00"' as base_calc_2_imp,
'"0.00"' as val_2_imp,
case when aliqipi = 0 then
'"'||tbnfc.valoritens||'"'
else
'"0.00"'
end as baseipi,

case when aliqipi = 0 then
'"'||valoripi||'"'
else
'"0.00"'
end,

case when aliqipi = 2 then
'"'||valoripi||'"'
else
'"0.00"'
end as isentas_ipi,

case when aliqipi = 1 then
'"'||valoripi||'"'
else
'"0.00"'
end as outros_ipi,
'"0.00"' as reducao_ipi,
'"0"' as form_num,
'" "' as ind_retencao,
'"00/00/00"' as data_retencao,
'"00/00/00"' as data_venc,
'"'||tbcfop.ctcontdeb||'"' as conta_debito,
'" "' as hist_debito,
'"'||tbcfop.ctcontcred||'"' as conta_credito,
'" "' as hist_credito,
'" "' as conta_desc_credito,
'" "' as conta_desc_debito,
'"'||numnf||'"',
'" "' as reg_siscomex,
'" "' as desp_siscomex,
'" "' as emb_sicomex,
'"0"' as val_siscomex,
'" "' as cod_moeda_siscomex,
'" "' as cod_pais_siscomex,
'" "' as redespacho,
'"'||valorfrete||'"',
'"'||valorseguro||'"',
'"'||outrasdepesas||'"',
'"'||valoriss||'"',
'"0.00"' as val_compra,
'" "' as nf_propria,
'" "' as sem_efeito,
'"'||tbforcodtransp||'"',
'" "' as via_transp,
'"'||qtdevol||'"','"'||volume||'"', '"'||pesobruto||'"', '"'||pesoliq||'"',
'" "' as identificacao,'"'||ufplacatransp||'"',
'" "' as identificacao2,'" "' as uf_veic2,
'" "' as identificacao3,'" "' as uf_veic3,
'" "' as di_num,
'"0.00"' as pis_valor,
'"0.00"' as cofins_valor,
'"0.00"' as bc_icms,
'"0.00"' as icms_antecip,
'"0.00"' as icms_antecip_pago,
'" "' as fundap,
'" "' as cod_antecip,
'" "' as tipo_receita, ALIQICMS, ALIQIPI
from tbnfc left join tbcfop on (tbnfc.nfcfopi = tbcfop.cfopi)
left join tbempresa on (tbnfc.unidade = tbempresa.id)
WHERE emissao is not null
;



/* View: NOTAS_FISCAIS_EE200 */
CREATE VIEW NOTAS_FISCAIS_EE200(
    NF_NUMERO,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    TBFOREST,
    TIPOTRANSP,
    VALORTOTALNF,
    ESPECIE_NF,
    CHAVE_ACESSO,
    SERIE,
    MODELO,
    RAZAO,
    RAIZ_CFOP,
    CANC,
    FRETE,
    SEGURO,
    DESPESAS,
    ITENS,
    PISCOFINS,
    PBRUTO,
    PLIQUIDO,
    VIA,
    CODTRANSP,
    PLACA1,
    IE_ST,
    VOLUMES,
    ESPECIE_VOL,
    IE_TRANSP,
    ESTADO_TRANSP,
    UF_PLACA1,
    PLACA2,
    UF_PLACA2,
    PLACA3,
    UF_PLACA3,
    SAIDA_MERCADORIA,
    CNPJ_SAIDA,
    UF_SAIDA,
    IE_SAIDA,
    RECEBIMENTO_MERCADORIA,
    CNPJ_RECEBIMENTO,
    UF_RECEBIMENTO,
    IE_RECEBIMENTO,
    UF_TRANSP,
    STAIMP,
    UNIDADE,
    TIPONOTA,
    NUMERO_NF,
    ORIGEM)
AS
select pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp, sum(valortotalnf),
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N', a.valorfrete, a.valorseguro, a.outrasdepesas,
'00001','00000000000000',a.pesobruto, a.pesoliq, '1','                    ','               ',
'                  ','000000000000001','VOLUME    ','                 ','  ','  ','               ','  ','               ',
'  ','0','              ','  ','                  ','0','              ','  ','                  ','  ',a.staimp, a.unidade, a.tipo,
cast(pedidocli as numeric(15,0)), 'RECEBIDAS'
from tbnfc a left join tbnatdoc c on (a.tipo_doc = c.natdoc) where sistema >='01.01.2013' and a.cfop not in('1.933', '2.933','3.933')
group by pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp,
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N',
a.valorfrete, a.valorseguro, a.outrasdepesas,
'00001','00000000000000',a.pesobruto, a.pesoliq, '1','                   ','               ',
'                  ',a.volume,a.especie,'                 ','  ','  ','               ','  ','               ',
'  ','0','              ','  ','                  ','0','              ','  ','                  ','  ', a.staimp, a.unidade, a.tipo, cast(pedidocli as numeric(15,0)), 'RECEBIDAS'
order by pedidocli
;



/* View: NOTAS_FISCAIS_EE201 */
CREATE VIEW NOTAS_FISCAIS_EE201(
    NF_NUMERO,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    TBFOREST,
    TIPOTRANSP,
    VALORTOTALNF,
    ESPECIE_NF,
    CHAVE_ACESSO,
    SERIE,
    MODELO,
    RAZAO,
    RAIZ_CFOP,
    CANC,
    CFOPI,
    CI,
    BASEICMS,
    ICMS,
    VALORICMS,
    VALORITENS,
    VALORICMSSUBST,
    BASEICMSSUBST,
    VALORIPI,
    TRIBPISCOFINS,
    ALIQPIS,
    ALIQCOFINS,
    VALORPIS,
    VALORCOFINS)
AS
select pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp, sum(valortotalnf),
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N', a.nfcfopi,

case when
b.codigo_integracao is null then 0
else b.codigo_integracao
end,
a.baseicms, a.icms, a.valoricms, a.valoritens, a.valoricmssubst, a.baseicmssubst, a.valoripi,
b.trib_piscofins, b.aliq_pis, b.aliq_cofins,
case when b.trib_piscofins = 0
then
case when b.aliq_pis > 0 then cast((a.valoritens * b.aliq_pis) / 100 as numeric(12,2))
else 0
end
else
0
end, 
case when b.trib_piscofins = 0
then
case when b.aliq_cofins > 0 then cast((a.valoritens * b.aliq_cofins) / 100 as numeric(12,2))
else 0
end
else
0
end
from tbnfc a left join tbcfop b on (a.nfcfopi = b.cfopi)
left join tbnatdoc c on (a.tipo_doc = c.natdoc)
where sistema >='01.01.2013' and a.cfop not in ('1.933','2.933','3.933')
group by pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp, valortotalnf,
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N', a.nfcfopi,
case when
b.codigo_integracao is null then 0
else b.codigo_integracao
end,
a.baseicms, a.icms, a.valoricms, a.valoritens, a.valoricmssubst, a.baseicmssubst, a.valoripi,
b.trib_piscofins, b.aliq_pis, b.aliq_cofins,
case when b.trib_piscofins = 0
then
case when b.aliq_pis > 0 then cast((a.valoritens * b.aliq_pis) / 100 as numeric(12,2))
else 0
end
else
0
end, 
case when b.trib_piscofins = 0
then
case when b.aliq_cofins > 0 then cast((a.valoritens * b.aliq_cofins) / 100 as numeric(12,2))
else 0
end
else
0
end
order by pedidocli
;



/* View: NOTAS_FISCAIS_EE222 */
CREATE VIEW NOTAS_FISCAIS_EE222(
    REGISTRO,
    TIPO,
    ESPECIE_NF,
    SERIE_NF,
    SUB_SERIE_NF,
    NUMERO_NF,
    CODCLI,
    N_ITEM,
    CFOP,
    CODIGO_PRODUTO,
    ICMS,
    QTDE,
    VALOR_MERCADORIA,
    VALOR_DESCONTO,
    BASE_ICMS,
    BASE_ST,
    VALOR_IPI,
    VALOR_UNITARIO,
    NUMERO_DI,
    BASE_IPI,
    VALOR_ICMS,
    ISENTOS_ICMS,
    OUTROS_ICMS,
    NUMERO_CUPOM_FISCAL,
    VALOR_ICMS_ST,
    MOV_FISICA,
    ISENTOS_IPI,
    OUTROS_IPI,
    BASE_ST_ORIGEM_DESTINO,
    ICMS_ST_REPASSAR,
    ICMS_ST_COMPLEMENTAR,
    ITEM_CANCELADO,
    ST_SAIDA,
    ISS,
    UNIDADE_COMERCIAL,
    CODIGO_NATUREZA_OPERACAO,
    DESCRICAO_COMPLEMENTAR,
    FATOR_CONVERSAO,
    ICMS_ST,
    ST_ICMS_TABA,
    ST_ICMS_TABB,
    ST_IPI,
    DISTINTAS_IPI,
    CONTA,
    FRETE_PRODUTO,
    FRETE_TOTAL,
    SEGURO_PRODUTO,
    SEGURO_TOTAL,
    DESPESAS_PRODUTO,
    DESPESAS_TOTAL,
    ACRESCIMO,
    REDUCAO_BASE_ICMS,
    VALOR_NAO_TRIB_BASE_ICMS,
    QTDE_CANCELADA,
    BASE_ICMS_REDUZIDA,
    DADOS_REDF,
    TOTALIZADOR,
    DESCONTO_INCONDICIONAL,
    CSOSN,
    SISTEMA,
    TRIB_PISCOFINS,
    ALIQ_PIS,
    ALIQ_COFINS,
    VALOR_PIS,
    VALOR_COFINS,
    BASE_PISCOFINS)
AS
select distinct
'E222',
'E',
c.tipo_fiscal, b.serie, '  ', a.item_nf,
a.codicli,
1,a.item_cfopi,
a.codigoitem, a.icms, a.qtdeitem, a.vlitem, 0, a.item_base_icms, a.item_base_icms_subst,
a.vlipi, a.vlunit, 0, 0, a.item_valor_icms, 0, 0, 0, a.item_valor_icms_subst,'N',
0,0,0,0,0,'N',' ','N',
a.und, '          ',f_left(a.descricao,50),
case when
a.und <> d.undusoitem then d.fatorconvitem
else
0
end,
0,
f_left(a.sittrib,1),
f_right(a.sittrib,2),'  ',
case when
b.modelo = '01' then 'M'
when b.modelo = '1B' then 'M'
when b.modelo = '04' then 'M'
when b.modelo = '55' then 'M'
else ' '
end,
'              ',
a.item_valor_frete,
case when b.valorfrete > 0
then 'S'
else 'N'
end,
a.item_valor_seguro,
case when b.valorseguro > 0
then 'S'
else 'N'
end,
a.item_valor_outros,
case when b.outrasdepesas > 0
then 'S'
else 'N'
end,
0,0,
0,
0,
case when a.vlitem > a.item_base_icms then
a.item_base_icms
else
0
end
,'4','  ','N','   ',B.sistema, e.trib_piscofins,
case
when e.trib_piscofins = 1 then 0
else
e.aliq_pis
end,
case when
e.trib_piscofins = 1 then 0
else
e.aliq_cofins
end,
case
when e.trib_piscofins = 1 then 0
else
cast((a.vlitem * e.aliq_pis)/100 as numeric(12,2))
end,
case when
e.trib_piscofins = 1 then 0
else
cast((a.vlitem * e.aliq_cofins)/100 as numeric(12,2))
end,
case when
e.trib_piscofins = 1 then 0
else
a.vlitem
end
from tbnfc b left join tbnatdoc c on (b.tipo_doc = c.natdoc) left join (tbitensnfc a left join tbitens d on (a.codigoitem = d.codigoitem)
left join tbcfop e on (a.item_cfopi = e.cfopi)
) on (b.pedidocli = a.item_nf and b.codcli = a.codicli)
where b.sistema >='01.01.2013' AND B.cfop not in('1.933','2.933','3.933')
;



/* View: NOTAS_FISCAIS_ENTRADA */
CREATE VIEW NOTAS_FISCAIS_ENTRADA(
    NUMNF,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    RAZAO,
    FANTASIA,
    CNPJCLI,
    INSCCLI,
    CPAG,
    STATUS,
    TIPO,
    CANC,
    CFOP,
    DESCCFOP,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    TBFORENDERTRANSP,
    TBFORBAIRROTRANSP,
    TBFORCEPTRANSP,
    TBFORCIDTRANSP,
    TBFORESTTRANSP,
    TIPOTRANSP,
    PLACATRANSP,
    UFPLACATRANSP,
    INSCTRANSP,
    CNPJTRANSP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSNF,
    ICMS,
    TF,
    BASEICMS,
    VALORICMS,
    VALORIPI,
    BASEICMSSUBST,
    VALORICMSSUBST,
    VALORITENS,
    VALORISS,
    VALORTOTALNF,
    VALORSERVICO,
    VALORFRETE,
    VALORSEGURO,
    OUTRASDEPESAS,
    QTDEVOL,
    VOLUME,
    ESPECIE,
    MARCA,
    PESOBRUTO,
    PESOLIQ,
    NOSSOPED,
    PEDIDOCLI,
    NFRECUSA,
    VEND,
    NOMEVEND,
    STAICMS,
    STAIPI,
    STASUFRAMA,
    STAIMP,
    STAEST,
    STAPED,
    STACOM,
    NFCFOPI,
    UNIDADE,
    TIPO_DOC,
    CHAVE_ACESSO,
    SERIE,
    MODELO)
AS
select numnf, emissao, sistema, saida, codcli, razao, fantasia, cnpjcli, insccli, cpag, status, tipo, canc, cfop, desccfop, tbforender, tbforbairro, tbforcep, tbforcid, tbforest, tbforendercob, tbforbairrocob, tbforcepcob, tbforcidcob, tbforestcob, tbforenderent, tbforbairroent, tbforcepent, tbforcident, tbforestent, tbforcodtransp, tbfornometransp, tbforendertransp, tbforbairrotransp, tbforceptransp, tbforcidtransp, tbforesttransp, tipotransp, placatransp, ufplacatransp, insctransp, cnpjtransp, comissaoven, comissaorep, comissaoint, comissaoext, obsnf, icms, tf, baseicms, valoricms, valoripi, baseicmssubst, valoricmssubst, valoritens, valoriss, valortotalnf, valorservico, valorfrete, valorseguro, outrasdepesas, qtdevol, volume, especie, marca, pesobruto, pesoliq, nossoped, pedidocli, nfrecusa, vend, nomevend, staicms, staipi, stasuframa, staimp, staest, staped, stacom, nfcfopi, unidade, tipo_doc, chave_acesso, serie, modelo
from tbnfc where tbnfc.nfcfopi <> '1.902.01'
;



/* View: NOTAS_FISCAIS_RETORNO */
CREATE VIEW NOTAS_FISCAIS_RETORNO(
    NUMNF,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    RAZAO,
    FANTASIA,
    CNPJCLI,
    INSCCLI,
    CPAG,
    STATUS,
    TIPO,
    CANC,
    CFOP,
    DESCCFOP,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    TBFORENDERTRANSP,
    TBFORBAIRROTRANSP,
    TBFORCEPTRANSP,
    TBFORCIDTRANSP,
    TBFORESTTRANSP,
    TIPOTRANSP,
    PLACATRANSP,
    UFPLACATRANSP,
    INSCTRANSP,
    CNPJTRANSP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSNF,
    ICMS,
    TF,
    BASEICMS,
    VALORICMS,
    VALORIPI,
    BASEICMSSUBST,
    VALORICMSSUBST,
    VALORITENS,
    VALORISS,
    VALORTOTALNF,
    VALORSERVICO,
    VALORFRETE,
    VALORSEGURO,
    OUTRASDEPESAS,
    QTDEVOL,
    VOLUME,
    ESPECIE,
    MARCA,
    PESOBRUTO,
    PESOLIQ,
    NOSSOPED,
    PEDIDOCLI,
    NFRECUSA,
    VEND,
    NOMEVEND,
    STAICMS,
    STAIPI,
    STASUFRAMA,
    STAIMP,
    STAEST,
    STAPED,
    STACOM,
    NFCFOPI,
    UNIDADE,
    TIPO_DOC,
    CHAVE_ACESSO,
    SERIE,
    MODELO)
AS
select numnf, emissao, sistema, saida, codcli, razao, fantasia, cnpjcli, insccli, cpag, status, tipo, canc, cfop, desccfop, tbforender, tbforbairro, tbforcep, tbforcid, tbforest, tbforendercob, tbforbairrocob, tbforcepcob, tbforcidcob, tbforestcob, tbforenderent, tbforbairroent, tbforcepent, tbforcident, tbforestent, tbforcodtransp, tbfornometransp, tbforendertransp, tbforbairrotransp, tbforceptransp, tbforcidtransp, tbforesttransp, tipotransp, placatransp, ufplacatransp, insctransp, cnpjtransp, comissaoven, comissaorep, comissaoint, comissaoext, obsnf, icms, tf, baseicms, valoricms, valoripi, baseicmssubst, valoricmssubst, valoritens, valoriss, valortotalnf, valorservico, valorfrete, valorseguro, outrasdepesas, qtdevol, volume, especie, marca, pesobruto, pesoliq, nossoped, pedidocli, nfrecusa, vend, nomevend, staicms, staipi, stasuframa, staimp, staest, staped, stacom, nfcfopi, unidade, tipo_doc, chave_acesso, serie, modelo
from tbnfc where tbnfc.nfcfopi = '1.902.01'
;



/* View: NOTAS_FISCAIS_SE200 */
CREATE VIEW NOTAS_FISCAIS_SE200(
    NF_NUMERO,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    TBFOREST,
    TIPOTRANSP,
    VALORTOTALNF,
    ESPECIE_NF,
    CHAVE_ACESSO,
    SERIE,
    MODELO,
    RAZAO,
    RAIZ_CFOP,
    CANC,
    FRETE,
    SEGURO,
    DESPESAS,
    ITENS,
    PISCOFINS,
    PBRUTO,
    PLIQUIDO,
    VIA,
    CODTRANSP,
    PLACA1,
    IE_ST,
    VOLUMES,
    ESPECIE_VOL,
    IE_TRANSP,
    ESTADO_TRANSP,
    UF_PLACA1,
    PLACA2,
    UF_PLACA2,
    PLACA3,
    UF_PLACA3,
    SAIDA_MERCADORIA,
    CNPJ_SAIDA,
    UF_SAIDA,
    IE_SAIDA,
    RECEBIMENTO_MERCADORIA,
    CNPJ_RECEBIMENTO,
    UF_RECEBIMENTO,
    IE_RECEBIMENTO,
    UF_TRANSP,
    STAIMP,
    UNIDADE,
    STACOM,
    TIPONOTA,
    NUMNF)
AS
select a.nf_numero, emissao, sistema, saida, codcli, tbforest, tipotransp, sum(valortotalnf),
'NFE', chave_acesso, '1', '55', razao, f_left(a.cfop, 1), a.canc, a.valorfrete, a.valorseguro, a.outrasdepesas,
'00001','00000000000000',a.pesobruto, a.pesoliq, '1','                    ','               ',
'                  ',a.qtdevol,f_left(a.especie,10),'                 ','  ','  ','               ','  ','               ',
'  ','0','              ','  ','                  ','0','              ','  ','                  ','  ', a.staimp, a.unidade, a.stacom, a.tipo, a.numnf
from tbnf a where sistema >='01.01.2013'
group by a.nf_numero, emissao, sistema, saida, codcli, tbforest, tipotransp,
'NFE', chave_acesso, '55', '1', razao, f_left(a.cfop, 1), a.canc, a.valorfrete, a.valorseguro, a.outrasdepesas,
'00001','00000000000000',a.pesobruto, a.pesoliq, '1','                   ','               ',
'                  ',a.qtdevol,f_left(a.especie,10),'                 ','  ','  ','               ','  ','               ',
'  ','0','              ','  ','                  ','0','              ','  ','                  ','  ', a.staimp, a.unidade, a.stacom, a.tipo, a.numnf
order by nf_numero
;



/* View: NOTAS_FISCAIS_SE201 */
CREATE VIEW NOTAS_FISCAIS_SE201(
    NF_NUMERO,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    TBFOREST,
    TIPOTRANSP,
    VALORTOTALNF,
    ESPECIE_NF,
    CHAVE_ACESSO,
    SERIE,
    MODELO,
    RAZAO,
    RAIZ_CFOP,
    CANC,
    CFOPI,
    CI,
    BASEICMS,
    ICMS,
    VALORICMS,
    VALORITENS,
    VALORICMSSUBST,
    BASEICMSSUBST,
    VALORIPI,
    TRIBPISCOFINS,
    ALIQPIS,
    ALIQCOFINS,
    VALORPIS,
    VALORCOFINS)
AS
select a.nf_numero, emissao, sistema, saida, codcli, tbforest, tipotransp, sum(valortotalnf),
'NFE', chave_acesso, '1', '55', razao, f_left(a.cfop, 1), a.canc, a.nfcfopi,
case when
b.codigo_integracao is null then 0
else
b.codigo_integracao
end,
a.baseicms, a.icms, a.valoricms, a.valoritens, a.valoricmssubst, a.baseicmssubst, a.valoripi,
b.trib_piscofins, b.aliq_pis, b.aliq_cofins,
case when b.trib_piscofins = 0
then
case when b.aliq_pis > 0 then cast((a.valoritens * b.aliq_pis) / 100 as numeric(12,2))
else 0
end
else
0
end, 
case when b.trib_piscofins = 0
then
case when b.aliq_cofins > 0 then cast((a.valoritens * b.aliq_cofins) / 100 as numeric(12,2))
else 0
end
else
0
end
from tbnf a left join tbcfop b on (a.nfcfopi = b.cfopi) where sistema >='01.01.2013'
group by a.nf_numero, emissao, sistema, saida, codcli, tbforest, tipotransp, valortotalnf,
'NFE', chave_acesso, '55', '1', razao, f_left(a.cfop, 1), a.canc, a.nfcfopi,
case when
b.codigo_integracao is null then 0
else
b.codigo_integracao
end,
a.baseicms, a.icms, a.valoricms, a.valoritens, a.valoricmssubst, a.baseicmssubst, a.valoripi,
b.trib_piscofins, b.aliq_pis, b.aliq_cofins,
case when b.trib_piscofins = 0
then
case when b.aliq_pis > 0 then cast((a.valoritens * b.aliq_pis) / 100 as numeric(12,2))
else 0
end
else
0
end, 
case when b.trib_piscofins = 0
then
case when b.aliq_cofins > 0 then cast((a.valoritens * b.aliq_cofins) / 100 as numeric(12,2))
else 0
end
else
0
end
order by nf_numero
;



/* View: NOTAS_FISCAIS_SE222 */
CREATE VIEW NOTAS_FISCAIS_SE222(
    REGISTRO,
    TIPO,
    ESPECIE_NF,
    SERIE_NF,
    SUB_SERIE_NF,
    NUMERO_NF,
    CODCLI,
    N_ITEM,
    CFOP,
    CODIGO_PRODUTO,
    ICMS,
    QTDE,
    VALOR_MERCADORIA,
    VALOR_DESCONTO,
    BASE_ICMS,
    BASE_ST,
    VALOR_IPI,
    VALOR_UNITARIO,
    NUMERO_DI,
    BASE_IPI,
    VALOR_ICMS,
    ISENTOS_ICMS,
    OUTROS_ICMS,
    NUMERO_CUPOM_FISCAL,
    VALOR_ICMS_ST,
    MOV_FISICA,
    ISENTOS_IPI,
    OUTROS_IPI,
    BASE_ST_ORIGEM_DESTINO,
    ICMS_ST_REPASSAR,
    ICMS_ST_COMPLEMENTAR,
    ITEM_CANCELADO,
    ST_SAIDA,
    ISS,
    UNIDADE_COMERCIAL,
    CODIGO_NATUREZA_OPERACAO,
    DESCRICAO_COMPLEMENTAR,
    FATOR_CONVERSAO,
    ICMS_ST,
    ST_ICMS_TABA,
    ST_ICMS_TABB,
    ST_IPI,
    DISTINTAS_IPI,
    CONTA,
    FRETE_PRODUTO,
    FRETE_TOTAL,
    SEGURO_PRODUTO,
    SEGURO_TOTAL,
    DESPESAS_PRODUTO,
    DESPESAS_TOTAL,
    ACRESCIMO,
    REDUCAO_BASE_ICMS,
    VALOR_NAO_TRIB_BASE_ICMS,
    QTDE_CANCELADA,
    BASE_ICMS_REDUZIDA,
    DADOS_REDF,
    TOTALIZADOR,
    DESCONTO_INCONDICIONAL,
    CSOSN,
    SISTEMA,
    TRIB_PISCOFINS,
    ALIQ_PIS,
    ALIQ_COFINS,
    VALOR_PIS,
    VALOR_COFINS,
    BASE_PISCOFINS,
    ITEMNF)
AS
select
'E222',
b.tipo,
'NFE', '1', '  ', cast(b.nf_numero as varchar(15)),
a.codicli,
1,a.cfopi,
a.codigoitem, a.icms, a.qtdeitem, a.vlitem, 0, a.base_icms, 0,
a.vlipi, a.vlunit, 0, 0, a.valor_icms, 0, 0, 0, 0,'N',
0,0,0,0,0,'N',' ','N',
a.und, '          ',f_left(a.descricao,50),
case when
a.und <> d.undusoitem then d.fatorconvitem
else
0
end,
0,
f_left(a.sittrib,1),
f_right(a.sittrib,2),'  ',
'M',
'              ',
0,
case when b.valorfrete > 0
then 'S'
else 'N'
end,
0,
case when b.valorseguro > 0
then 'S'
else 'N'
end,
0,
case when b.outrasdepesas > 0
then 'S'
else 'N'
end,
0,0,
0,
0,
case when a.vlitem > a.base_icms
then a.base_icms
else
0
end,'4','  ','N','   ',B.sistema,
e.trib_piscofins,
case
when e.trib_piscofins = 1 then 0
else
e.aliq_pis
end,
case when
e.trib_piscofins = 1 then 0
else
e.aliq_cofins
end,
case
when e.trib_piscofins = 1 then 0
else
cast((a.vlitem * e.aliq_pis)/100 as numeric(12,2))
end,
case when
e.trib_piscofins = 1 then 0
else
cast((a.vlitem * e.aliq_cofins)/100 as numeric(12,2))
end,
case when
e.trib_piscofins = 1 then 0
else
a.vlitem
end , a.iditemnf
from tbitensnf a left join tbnf b on (a.idnumnf = b.numnf)
left join tbitens d on (a.codigoitem = d.codigoitem)
left join tbcfop e on (a.cfopi = e.cfopi)
where b.sistema >= '01.01.2013'
;



/* View: NOTAS_FISCAIS_SR200 */
CREATE VIEW NOTAS_FISCAIS_SR200(
    NF_NUMERO,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    TBFOREST,
    TIPOTRANSP,
    VALORTOTALNF,
    ESPECIE_NF,
    CHAVE_ACESSO,
    SERIE,
    MODELO,
    RAZAO,
    RAIZ_CFOP,
    CANC,
    FRETE,
    SEGURO,
    DESPESAS,
    ITENS,
    PISCOFINS,
    PBRUTO,
    PLIQUIDO,
    VIA,
    CODTRANSP,
    PLACA1,
    IE_ST,
    VOLUMES,
    ESPECIE_VOL,
    IE_TRANSP,
    ESTADO_TRANSP,
    UF_PLACA1,
    PLACA2,
    UF_PLACA2,
    PLACA3,
    UF_PLACA3,
    SAIDA_MERCADORIA,
    CNPJ_SAIDA,
    UF_SAIDA,
    IE_SAIDA,
    RECEBIMENTO_MERCADORIA,
    CNPJ_RECEBIMENTO,
    UF_RECEBIMENTO,
    IE_RECEBIMENTO,
    UF_TRANSP,
    STAIMP,
    UNIDADE,
    TIPONOTA,
    NUMERO_NF,
    ORIGEM)
AS
select pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp, sum(valortotalnf),
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N', a.valorfrete, a.valorseguro, a.outrasdepesas,
'00001','00000000000000',a.pesobruto, a.pesoliq, '1','                    ','               ',
'                  ','000000000000001','VOLUME    ','                 ','  ','  ','               ','  ','               ',
'  ','0','              ','  ','                  ','0','              ','  ','                  ','  ',a.staimp, a.unidade, a.tipo,
cast(pedidocli as numeric(15,0)), 'SERVICOS'
from tbnfc a left join tbnatdoc c on (a.tipo_doc = c.natdoc) where sistema >='01.01.2013' and a.cfop in('1.933','2.933','3.933')
group by pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp, valortotalnf,
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N',
a.valorfrete, a.valorseguro, a.outrasdepesas,
'00001','00000000000000',a.pesobruto, a.pesoliq, '1','                   ','               ',
'                  ',a.volume,a.especie,'                 ','  ','  ','               ','  ','               ',
'  ','0','              ','  ','                  ','0','              ','  ','                  ','  ', a.staimp, a.unidade, a.tipo, cast(pedidocli as numeric(15,0)), 'RECEBIDAS'
order by pedidocli
;



/* View: NOTAS_FISCAIS_SR201 */
CREATE VIEW NOTAS_FISCAIS_SR201(
    NF_NUMERO,
    EMISSAO,
    SISTEMA,
    SAIDA,
    CODCLI,
    TBFOREST,
    TIPOTRANSP,
    VALORTOTALNF,
    ESPECIE_NF,
    CHAVE_ACESSO,
    SERIE,
    MODELO,
    RAZAO,
    RAIZ_CFOP,
    CANC,
    CFOPI,
    CI,
    BASEICMS,
    ICMS,
    VALORICMS,
    VALORITENS,
    VALORICMSSUBST,
    BASEICMSSUBST,
    VALORIPI,
    TRIBPISCOFINS,
    ALIQPIS,
    ALIQCOFINS,
    VALORPIS,
    VALORCOFINS)
AS
select pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp, sum(valortotalnf),
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N', a.nfcfopi,

case when
b.codigo_integracao is null then 0
else b.codigo_integracao
end,
a.baseicms, a.icms, a.valoricms, a.valoritens, a.valoricmssubst, a.baseicmssubst, a.valoripi,
b.trib_piscofins, b.aliq_pis, b.aliq_cofins,
case when b.trib_piscofins = 0
then
case when b.aliq_pis > 0 then cast((a.valoritens * b.aliq_pis) / 100 as numeric(12,2))
else 0
end
else
0
end, 
case when b.trib_piscofins = 0
then
case when b.aliq_cofins > 0 then cast((a.valoritens * b.aliq_cofins) / 100 as numeric(12,2))
else 0
end
else
0
end
from tbnfc a left join tbcfop b on (a.nfcfopi = b.cfopi)
left join tbnatdoc c on (a.tipo_doc = c.natdoc)
where sistema >='01.01.2013' and a.cfop in('1.933','2.933','3.933')
group by pedidocli, emissao, sistema, saida, codcli, tbforest, tipotransp, valortotalnf,
c.tipo_fiscal, chave_acesso, serie, modelo, razao, f_left(a.cfop,1), 'N', a.nfcfopi,
case when
b.codigo_integracao is null then 0
else b.codigo_integracao
end,
a.baseicms, a.icms, a.valoricms, a.valoritens, a.valoricmssubst, a.baseicmssubst, a.valoripi,
b.trib_piscofins, b.aliq_pis, b.aliq_cofins,
case when b.trib_piscofins = 0
then
case when b.aliq_pis > 0 then cast((a.valoritens * b.aliq_pis) / 100 as numeric(12,2))
else 0
end
else
0
end, 
case when b.trib_piscofins = 0
then
case when b.aliq_cofins > 0 then cast((a.valoritens * b.aliq_cofins) / 100 as numeric(12,2))
else 0
end
else
0
end
order by pedidocli
;



/* View: NOTAS_FISCAIS_SR222 */
CREATE VIEW NOTAS_FISCAIS_SR222(
    REGISTRO,
    TIPO,
    ESPECIE_NF,
    SERIE_NF,
    SUB_SERIE_NF,
    NUMERO_NF,
    CODCLI,
    N_ITEM,
    CFOP,
    CODIGO_PRODUTO,
    ICMS,
    QTDE,
    VALOR_MERCADORIA,
    VALOR_DESCONTO,
    BASE_ICMS,
    BASE_ST,
    VALOR_IPI,
    VALOR_UNITARIO,
    NUMERO_DI,
    BASE_IPI,
    VALOR_ICMS,
    ISENTOS_ICMS,
    OUTROS_ICMS,
    NUMERO_CUPOM_FISCAL,
    VALOR_ICMS_ST,
    MOV_FISICA,
    ISENTOS_IPI,
    OUTROS_IPI,
    BASE_ST_ORIGEM_DESTINO,
    ICMS_ST_REPASSAR,
    ICMS_ST_COMPLEMENTAR,
    ITEM_CANCELADO,
    ST_SAIDA,
    ISS,
    UNIDADE_COMERCIAL,
    CODIGO_NATUREZA_OPERACAO,
    DESCRICAO_COMPLEMENTAR,
    FATOR_CONVERSAO,
    ICMS_ST,
    ST_ICMS_TABA,
    ST_ICMS_TABB,
    ST_IPI,
    DISTINTAS_IPI,
    CONTA,
    FRETE_PRODUTO,
    FRETE_TOTAL,
    SEGURO_PRODUTO,
    SEGURO_TOTAL,
    DESPESAS_PRODUTO,
    DESPESAS_TOTAL,
    ACRESCIMO,
    REDUCAO_BASE_ICMS,
    VALOR_NAO_TRIB_BASE_ICMS,
    QTDE_CANCELADA,
    BASE_ICMS_REDUZIDA,
    DADOS_REDF,
    TOTALIZADOR,
    DESCONTO_INCONDICIONAL,
    CSOSN,
    SISTEMA,
    TRIB_PISCOFINS,
    ALIQ_PIS,
    ALIQ_COFINS,
    VALOR_PIS,
    VALOR_COFINS,
    BASE_PISCOFINS)
AS
select distinct
'E222',
'E',
c.tipo_fiscal, b.serie, '  ', a.item_nf,
a.codicli,
1,a.item_cfopi,
a.codigoitem, a.icms, a.qtdeitem, a.vlitem, 0, a.item_base_icms, a.item_base_icms_subst,
a.vlipi, a.vlunit, 0, 0, a.item_valor_icms, 0, 0, 0, a.item_valor_icms_subst,'N',
0,0,0,0,0,'N',' ','N',
a.und, '          ',f_left(a.descricao,50),
case when
a.und <> d.undusoitem then d.fatorconvitem
else
0
end,
0,
f_left(a.sittrib,1),
f_right(a.sittrib,2),'  ',
case when
b.modelo = '01' then 'M'
when b.modelo = '1B' then 'M'
when b.modelo = '04' then 'M'
when b.modelo = '55' then 'M'
else ' '
end,
'              ',
a.item_valor_frete,
case when b.valorfrete > 0
then 'S'
else 'N'
end,
a.item_valor_seguro,
case when b.valorseguro > 0
then 'S'
else 'N'
end,
a.item_valor_outros,
case when b.outrasdepesas > 0
then 'S'
else 'N'
end,
0,0,
0,
0,
case when a.vlitem > a.item_base_icms then
a.item_base_icms
else
0
end
,'4','  ','N','   ',B.sistema, e.trib_piscofins,
case
when e.trib_piscofins = 1 then 0
else
e.aliq_pis
end,
case when
e.trib_piscofins = 1 then 0
else
e.aliq_cofins
end,
case
when e.trib_piscofins = 1 then 0
else
cast((a.vlitem * e.aliq_pis)/100 as numeric(12,2))
end,
case when
e.trib_piscofins = 1 then 0
else
cast((a.vlitem * e.aliq_cofins)/100 as numeric(12,2))
end,
case when
e.trib_piscofins = 1 then 0
else
a.vlitem
end
from tbnfc b left join tbnatdoc c on (b.tipo_doc = c.natdoc) left join (tbitensnfc a left join tbitens d on (a.codigoitem = d.codigoitem)
left join tbcfop e on (a.item_cfopi = e.cfopi)
) on (b.pedidocli = a.item_nf and b.codcli = a.codicli)
where b.sistema >='01.01.2013' AND B.cfop in('1.933','2.933','3.933')
;



/* View: NOTAS_REC_EMBALAGEM */
CREATE VIEW NOTAS_REC_EMBALAGEM(
    NUMNF,
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    VALORICMS,
    VALORIPI,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    VLITEMIPI,
    IPI,
    ICMS,
    DESENHO,
    NUMPED,
    STACOM)
AS
select
numnf, emissao, codcli,NFCFOPI,CFOP,DESCCFOP, razao, fantasia,VALORTOTALNF,TBNFc.valoricms, TBNFc.valoripi, tipo, canc, vend, TBNFc.status, NOMEVEND,
iditemnf, iditemped, codigoitem,DESCRICAO, tbnfc.pedidocli, qtdeitem,und, vlunit, vlitem,tbitensnfc.vlipi,IPI,TBNFc.icms ,  desenho, numped, STACOM
from tbnfc join tbitensnfc on (idnumnf = numnf) WHERE CFOP IN ('1.921','2.921')
;



/* View: NOTAS_RECEBIDAS */
CREATE VIEW NOTAS_RECEBIDAS(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    FANTASIA,
    TIPO,
    VEND,
    NOMEVEND,
    STAEST,
    STAPED,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    NF_FORNECEDOR,
    QTDEITEM,
    VLCOMPRA,
    VLITEM,
    FATOR_IMPOSTOS,
    VLUNIT,
    NUMMPED,
    UND,
    NR,
    GRUPOITEM,
    FATORCONVITEM,
    MES_BASE,
    ANO_BASE,
    UNIDADE)
AS
select
numnf, emissao, sistema, codcli, fantasia, tipo, vend, nomevend, staest, staped,
iditemnf, iditemped, tbitensnfc.codigoitem , tbnfc.pedidocli, qtdeitem, cast(vlunit*(1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100)) as numeric(12,4)),cast(vlitem*(1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100))as numeric(12,4)),1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100),
cast((vlunit*(1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100)))/fatorconvitem as numeric(12,4)),
numped,und,nr , tbitens.grupoitem, tbitens.fatorconvitem,
f_padleft(f_month(sistema),'0',2),
f_year(sistema), tbnfc.unidade 
from tbnfc join tbitensnfc join tbitens on (tbitensnfc.codigoitem = tbitens.codigoitem)   on (idnumnf = numnf)
where staest = 1  and tbitens.grupoitem in ('01','04','11','18') and sistema between '01.04.2009' and '30.04.2009' order by tbitensnfc.codigoitem, sistema
;



/* View: NOTAS_RECEBIDAS_SERV */
CREATE VIEW NOTAS_RECEBIDAS_SERV(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    FANTASIA,
    TIPO,
    VEND,
    NOMEVEND,
    STAEST,
    STAPED,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    NF_FORNECEDOR,
    QTDEITEM,
    VLCOMPRA,
    VLITEM,
    FATOR_IMPOSTOS,
    VLUNIT,
    NUMMPED,
    UND,
    NR,
    GRUPOITEM,
    FATORCONVITEM,
    MES_BASE,
    ANO_BASE,
    UNIDADE,
    STATUS,
    NF_SAIDA)
AS
select
numnf, emissao, sistema, codcli, fantasia, tipo, vend, nomevend, staest, staped,
iditemnf, iditemped, tbitensnfc.codigoitem , tbnfc.pedidocli, qtdeitem, cast(vlunit*(1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100)) as numeric(12,4)),cast(vlitem*(1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100))as numeric(12,4)),1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100),
cast((vlunit*(1-(cast((tbitensnfc.icms+9.25)as numeric(8,4))/100)))/fatorconvitem as numeric(12,4)),
numped,und,nr , tbitens.grupoitem, tbitens.fatorconvitem,
f_padleft(f_month(sistema),'0',2),
f_year(sistema), tbnfc.unidade, TBNFC.status, tbitensnfc.nfsaida 
from tbnfc join tbitensnfc join tbitens on (tbitensnfc.codigoitem = tbitens.codigoitem)   on (idnumnf = numnf)
where staest = 1 and status = 1 and sistema >='01.11.2010' order by TBNFC.codcli, TBNFC.sistema
;



/* View: NOTAS_REG */
CREATE VIEW NOTAS_REG(
    ENTRADA,
    NOTA,
    EMITENTE,
    CNPJ,
    VALOR)
AS
select sistema, pedidocli, razao,
f_replace(f_replace(f_replace(cnpjcli,'.',''),'-',''),'/',''), valortotalnf
from tbnfc where sistema between '01.01.2009' and '20.08.2010'
;



/* View: NOTAS_SAIDA_EXP */
CREATE VIEW NOTAS_SAIDA_EXP(
    NOTA,
    LINHA,
    FILIAL,
    CNPJ_FILIAL,
    CNPJCLI,
    NFCFOPI,
    NUMNF_INICIO,
    NUMNF_FIM,
    MODELO,
    ESPECIE,
    SERIE,
    SISTEMA,
    EMISSAO,
    UF_ORIGEM,
    UF_DESTINO,
    COD_FISCAL_MUN,
    IND_BASE_RED,
    IND_CONTRIB,
    CANC,
    IND_PAG,
    TIPOFRETE,
    OBS_NF,
    ICMS,
    VALORTOTALNF,
    BASEICMS,
    VALORICMS,
    ISENTA_ICMS,
    OUTROS_ICMS,
    IPI_EMBUT,
    VAL_AC_FIN,
    VAL_DESC,
    BASE_CALC_1_IMP,
    VAL_1_IMP,
    BASE_CALC_2_IMP,
    VAL_2_IMP,
    BASEIPI,
    VALORIPI,
    ISENTAS_IPI,
    OUTROS_IPI,
    REDUCAO_IPI,
    CHAVE_SEFAZ,
    HISTORICO_CONTABIL,
    VALORFRETE,
    VALORSEGURO,
    OUTRASDEPESAS,
    VIA_TRANSP,
    QTDEVOL,
    VOLUME,
    PESOBRUTO,
    PESOLIQ,
    IDENTIFICACAO,
    UFPLACATRANSP,
    IDENTIFICACAO2,
    UF_VEIC2,
    IDENTIFICACAO3,
    UF_VEIC3,
    PIS_VALOR,
    COFINS_VALOR,
    ALIQICMS,
    ALIQIPI)
AS
select
numnf,
'"1"' as linha,
'"'||tbnf.unidade||'"' as filial,
'"'||tbempresa.cnpj||'"' as cnpj_filial,

case when f_stringlength(cnpjcli)<14 then
    case when tbfor.tbforcodant > 0 then
    '"'||tbfor.tbforcodant||'"'
    else
    '"'||'C'||tbfor.tbforcod||'"'
    end
else
'"'||cnpjcli||'"'
end,
'"'||tbnf.nfcfopi||'"',
'"'||nf_numero||'"',
'"'||nf_numero||'"',
'"55"' as modelo,
'"NFE"' as especie,
'"0"' as serie,
'"'|| f_padleft(f_dayofmonth(sistema),'0',2) ||'/' || f_padleft(f_month(sistema),'0',2)||'/'||f_year(sistema)||'"',
'"'|| f_padleft(f_dayofmonth(emissao),'0',2) ||'/' || f_padleft(f_month(emissao),'0',2)||'/'||f_year(emissao)||'"',
'"SP"' AS uf_origem,
case when f_left(tbcfop.cfop,1) = '7' then
'"EX"'
else
'"'||tbfor.tbforest||'"'
end,
'"0"' AS cod_fiscal_mun,
'"N"' AS ind_base_red,
'"S"' AS ind_contrib,
'"'||canc||'"',
case (CPAG)
when 'A VISTA' then '"V"'
ELSE '"P"'
end,
case (tipotransp)
when 0 then '"F"' else '"C"'
end,
'" "' AS obs_nf,
case when aliqicms = 0 then
'"'||icms||'"'
else
'"0.00"'
end, 
'"'||valortotalnf||'"',

case when aliqicms = 0 then
'"'||baseicms||'"'
else
'"0.00"'
end
,
case when aliqicms = 0 then
'"'||valoricms||'"'
else
'"0.00"'
end,
case when aliqicms = 2 then
    case when valoricms = 0 then
    '"'||valoritens||'"'
    else
    '"'||valoricms||'"'
    end
    else
    '"0.00"'
    end as isenta_icms,
case when aliqicms = 1 then
    case when valoricms = 0 then
    '"'||valoritens||'"'
    else
    '"'||valoricms||'"'
    end
    else
'"0.00"' end as outros_icms,
case  when aliqipi = 0 then
'"'||valoripi||'"'
else
'"0.00"' end as ipi_embut,
'"0.00"' as val_ac_fin,
'"0.00"' as val_desc,
'"0.00"' as base_calc_1_imp,
'"0.00"' as val_1_imp,
'"0.00"' as base_calc_2_imp,
'"0.00"' as val_2_imp,
case when aliqipi = 0 then
'"'||tbnf.valoritens||'"'
else
'"0.00"' end as baseipi,
case when aliqipi = 0 then
'"'||valoripi||'"'
else
'"0.00"' end ,
case when aliqipi = 2 then
case when  valoripi = 0 then
'"'||tbnf.valoritens||'"'
else
'"'||valoripi||'"'
end
else
'"0.00"' end as isentas_ipi,
case when aliqipi = 1 then
case when  valoripi = 0 then
'"'||tbnf.valoritens||'"'
else
'"'||valoripi||'"'
end
else
'"0.00"' end as outros_ipi,
'"0.00"' as reducao_ipi,
'"'||tbnf.chave_acesso||'"',
'"SAIDA;'||
tbnf.nfcfopi 
||';'||
case
WHEN TBNF.nossoped IS NULL THEN '000000'
ELSE f_padleft(TBNF.nossoped,'0',6)
end ||';'||
case 
WHEN TBNF.nf_numero IS NULL THEN '000000'
ELSE f_padleft(TBNF.NF_NUMERO,'0',6)
END
||';'||
CASE
WHEN TBNF.cnpjcli is NULL THEN tbnf.codcli
ELSE TBNF.cnpjcli
END
||';'||
CASE
WHEN TBNF.fantasia is NULL THEN ''
ELSE TBNF.fantasia
END
||';NF_SAIDA"',
'"'||valorfrete||'"',
'"'||valorseguro||'"',
'"'||outrasdepesas||'"',
'" "' as via_transp,
'"'||qtdevol||'"','"'||volume||'"', '"'||pesobruto||'"', '"'||pesoliq||'"',
'" "' as identificacao,'"'||ufplacatransp||'"',
'" "' as identificacao2,'" "' as uf_veic2,
'" "' as identificacao3,'" "' as uf_veic3,
'"0.00"' as pis_valor,
'"0.00"' as cofins_valor,
aliqicms, aliqipi
from tbnf left join tbcfop on (tbnf.nfcfopi = tbcfop.cfopi)
left join tbfor on (tbnf.codcli = tbfor.tbforcod) left join tbempresa on (tbnf.unidade = tbempresa.id)
WHERE emissao is not null
;



/* View: NOTAS_TEMP */
CREATE VIEW NOTAS_TEMP(
    NUMNF,
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    VALORICMS,
    VALORIPI,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    VLITEMIPI,
    IPI,
    ICMS,
    DESENHO,
    NUMPED,
    FCONV,
    STACOM,
    COMPLEM,
    NOTA)
AS
select
numnf, emissao, codcli,NFCFOPI,CFOP,DESCCFOP, razao, fantasia,VALORTOTALNF,TBNF.valoricms, TBNF.valoripi, tipo, canc, vend, TBNF.status, NOMEVEND,
iditemnf, iditemped, codigoitem,DESCRICAO, tbitensnf.pedidocli, qtdeitem,und, vlunit, vlitem,tbitensnf.vlipi,IPI,TBNF.icms ,  desenho, numped, FCONV, STACOM, tbitensnf.textolegal, tipos_saidas.nota 
from tbnf left join tipos_saidas  left join tbitensnf on(tbnf.stacom = tipos_saidas.id) on (idnumnf = numnf)
where tbitensnf.codigoitem = '16.02.001.126-5' order by codigoitem
;



/* View: NOTAS_TRAT */
CREATE VIEW NOTAS_TRAT(
    SISTEMA,
    CODCLI,
    FANTASIA,
    CODIGOITEM,
    UND,
    VLUNIT,
    N_ET,
    STATUS)
AS
select max(sistema), codcli, fantasia, codigoitem, notasfiscaisc.und, notasfiscaisc.vlunit,
tbpropitemc.et  ,notasfiscaisc.status
 from notasfiscaisc join tbpropitemc on (notasfiscaisc.numped = tbpropitemc.idnumped and
 notasfiscaisc.codigoitem = tbpropitemc.codprod)
 group by codcli, fantasia, codigoitem, notasfiscaisc.und, notasfiscaisc.vlunit,
tbpropitemc.et  ,notasfiscaisc.status
 having tbpropitemc.et is not null
 and tbpropitemc.et <> '-' and tbpropitemc.et <> '000-' and notasfiscaisc.status = 1
;



/* View: NOTAS2 */
CREATE VIEW NOTAS2(
    NOTA,
    IDNOTA,
    IDITEM,
    CODIGOITEM,
    QTDEITEM,
    CFOP,
    EMISSAO,
    CODCLI)
AS
select a.pedidocli, a.numnf, b.idnumnf, b.codigoitem, b.qtdeitem, a.cfop, A.emissao, a.codcli
from tbnfc a left join tbitensnfc b on (a.numnf = b.idnumnf)
;



/* View: NOTASFISCAIS */
CREATE VIEW NOTASFISCAIS(
    NUMNF,
    SISTEMA,
    EMISSAO,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    VALORICMS,
    VALORIPI,
    TIPO,
    OPERACAO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    VLITEMIPI,
    VLTOT,
    IPI,
    ICMS,
    DESENHO,
    NUMPED,
    FCONV,
    STACOM,
    COMPLEM,
    UNIDADE,
    NF_NUMERO,
    NF_REFERENCIA,
    N_ET)
AS
select
numnf, tbnf.sistema,  tbnf.emissao, tbnf.codcli,tbnf.NFCFOPI,tbnf.CFOP,tbnf.DESCCFOP, tbnf.razao, fantasia,VALORTOTALNF,TBNF.valoricms, TBNF.valoripi, TBNF.tipo, TBNF.stacom, canc, vend, TBNF.status, NOMEVEND,
iditemnf, iditemped, codigoitem,DESCRICAO, tbitensnf.pedidocli, qtdeitem,tbitensnf.und, tbitensnf.vlunit, tbitensnf.vlitem,tbitensnf.vlipi, tbitensnf.vltot,  tbitensnf.IPI,TBNF.icms ,  tbitensnf.desenho, tbitensnf.numped, FCONV, STACOM, textolegal, tbnf.unidade
,nf_numero, tbitensnf.nf_referencia, tbpropitemc.et 
from tbnf join (tbitensnf left join tbpropitemc on (tbitensnf.iditemped = tbpropitemc.iditem)) on (idnumnf = numnf)
;



/* View: NOTASFISCAISC_SERV */
CREATE VIEW NOTASFISCAISC_SERV(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    NFCFOPI,
    CFOP,
    DESCCFOP,
    RAZAO,
    FANTASIA,
    VALORTOTAL,
    TIPO,
    CANC,
    VEND,
    STATUS,
    NOMEVEND,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    UND,
    VLUNIT,
    VLITEM,
    DESENHO,
    NUMPED,
    IPI,
    ICMS,
    VLTOT,
    VLIPI,
    NR,
    NFRECUSA,
    NFSAIDA,
    N_OS,
    N_ET,
    QTD_VOL,
    VOLUME,
    ESPECIFICACAO,
    UNIDADE,
    PESO_LIQ,
    CC1,
    CC2,
    CC3,
    CC4,
    CC5,
    CNPJ,
    STAEST)
AS
select
tbnfc.numnf, tbnfc.emissao,sistema, tbnfc.codcli,tbnfc.NFCFOPI, tbnfc.CFOP,tbnfc.desccfop,  tbnfc.razao, tbnfc.fantasia,VALORTOTALNF, tbnfc.tipo, tbnfc.canc, tbnfc.vend, TBNFC.status, tbnfc.NOMEVEND,
tbitensnfc.iditemnf, tbitensnfc.iditemped, tbitensnfc.codigoitem, tbitensnfc.DESCRICAO, tbNFC.pedidocli, tbitensnfc.qtdeitem,tbitensnfc.und, tbitensnfc.vlunit, tbitensnfc.vlitem, tbitensnfc.desenho, tbitensnfc.numped ,
tbitensnfc.ipi, tbnfc.icms, vltot, vlipi, nr, nfrecusa, TBITENSNFC.nfsaida , notas_serv.n_os ,
case tbpropitemc.et
when '000-' then '0000'
when '-' then '0000'
when '' then '0000'
else f_padleft(tbpropitemc.et,'0',4)
end
,tbitensnfc.sittrib,TBITENSNFC.classfiscal,  tbpropitemc.descorcam, tbnfc.unidade,
tbitens.pesoliqitem, tbpropitemc.cc1, tbpropitemc.cc2,  tbpropitemc.cc3, tbpropitemc.cc4,  tbpropitemc.cc5 , tbnfc.cnpjcli,
tbnfc.staest 
from tbnfc join tbitensnfc left join tbpropitemc on(tbpropitemc.iditem = tbitensnfc.iditemped) on (idnumnf = numnf)
left join tbitens on (tbitensnfc.codigoitem = tbitens.codigoitem)
left join notas_serv on (tbitensnfc.nfsaida  = cast(notas_serv.nf_numero as varchar(20)) and tbitensnfc.codigoitem = notas_serv.codigoitem)
where tbnfc.sistema >= '01.09.2010' and tbnfc.status = 1
;



/* View: NOVAS_PERMISSOES */
CREATE VIEW NOVAS_PERMISSOES(
    PERMID,
    PERMNOME,
    PERMCOD,
    ID_USUARIO,
    ID_PERMISSAO)
AS
select a.permid, a.permnome,a.permcod, b.id_usuario, b.id_permissao from tb_perm_padrao a
LEFT JOIN tb_perm_user b on (a.PERMID = b.ID_PERMISSAO)
;



/* View: NOVAS_PERMISSOES2 */
CREATE VIEW NOVAS_PERMISSOES2(
    PERMID,
    PERMNOME,
    PERMCOD,
    PERMMODULO)
AS
select permid, permnome,PERMCOD,tb_perm_padrao.permmodulo
 from tb_perm_padrao
order by permid
;



/* View: NR_CNS */
CREATE VIEW NR_CNS(
    IRDATA,
    IRNUM,
    IRCODFOR,
    IRFORFAN,
    IRRC,
    IRMAT,
    IRCODMAT,
    IRNF,
    IRCERT,
    IRRA,
    IRQTD,
    IRUND,
    IRDISPFINAL,
    IRSAC,
    IROBS,
    IRINSPETOR,
    IRREG,
    IRNAT,
    IRRNC,
    IRDESVIO,
    IRAC,
    IRENT,
    IRDEM,
    IRNUMANT,
    IRBASE,
    IRLIBPARC,
    CODIGOITEM,
    NOMEITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    CODCLITEM,
    NOMECLITEM)
AS
select irdata, irnum, ircodfor, irforfan, irrc,
irmat, ircodmat, irnf, ircert, irra, irqtd, irund, irdispfinal,
irsac, irobs, irinspetor, irreg, irnat, irrnc, irdesvio, irac,irent,irdem,irnumant,irbase,irlibparc,
codigoitem, nomeitem, desenhoitem, revdesenhoitem, codclitem, nomeclitem
from tbir join tbitens on(tbir.ircodmat = tbitens.codigoitem)
;



/* View: NR_RECEB */
CREATE VIEW NR_RECEB(
    IDNUMNF,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    PEDIDOCLI,
    QTDEITEM,
    VLUNIT,
    IPI,
    ICMS,
    VLITEM,
    VLTOT,
    VLIPI,
    CODICLI,
    DESENHO,
    CODVEN,
    CLASSFISCAL,
    SITTRIB,
    UND,
    NR,
    BAIXAEST,
    NUMPED,
    NFSAIDA,
    PRAZOCOT,
    PRIPED)
AS
select
tbitensnfc.idnumnf, tbitensnfc.iditemnf, tbitensnfc.iditemped, tbitensnfc.codigoitem, descricao, tbitensnfc.pedidocli, qtdeitem, tbitensnfc.vlunit, tbitensnfc.ipi, tbitensnfc.icms, tbitensnfc.vlitem, tbitensnfc.vltot, tbitensnfc.vlipi, tbitensnfc.codicli, tbitensnfc.desenho, tbitensnfc.codven, tbitensnfc.classfiscal, tbitensnfc.sittrib, tbitensnfc.und, tbitensnfc.nr, tbitensnfc.baixaest, tbitensnfc.numped, tbitensnfc.nfsaida,
pedidoc.prazocot, pedidoc.priped
 from tbitensnfc join pedidoc on (iditemped = iditem)
;



/* View: ULTIMA_OPERACAO */
CREATE VIEW ULTIMA_OPERACAO(
    ARVORE,
    SEQ)
AS
select arvore, max(seq) as ult_op
from fluxo_processo where fluxo_processo.custo = 1
group by arvore
;



/* View: OPERACAO_FINAL */
CREATE VIEW OPERACAO_FINAL(
    ARVORE,
    SEQ,
    PRODUTO,
    MNUM,
    DESCROPER,
    PCHORA)
AS
select ultima_operacao.arvore, ultima_operacao.seq,
produto, mnum, descroper, pchora
from ultima_operacao left join fluxo_processo on (ultima_operacao.arvore = fluxo_processo.arvore
and ultima_operacao.seq = fluxo_processo.seq)
;



/* View: OPERACOES */
CREATE VIEW OPERACOES(
    ARVORE,
    PRODUTO,
    SEQ,
    SETOR,
    NOME_SETOR,
    CC,
    NOME_CC,
    MAQUINA,
    NOME_MAQ,
    SETPECA,
    DESCROPER,
    PCHORA)
AS
select arvore, produto, seq, tbarvoreproc.setor,nomesetor,tbsetor.ncc, ccusto.nome, idrec1,NOMEREC, setpeca, descroper, pchora
 from tbarvoreproc LEFT JOIN TBRECURSO ON (TBRECURSO.idrec = IDREC1)
 left join tbsetor on (tbsetor.idsetor = tbarvoreproc.setor)
 left join ccusto on (ccusto.idccusto = tbsetor.idccusto)

 order by produto, seq
;



/* View: OPERACOES_ADI */
CREATE VIEW OPERACOES_ADI(
    CODIGO,
    DESCRICAO,
    NUM_OPERACAO,
    OPERACAO,
    PCS_CICLO,
    PCS_HORA,
    TIPO,
    CUSTO)
AS
select f_replace(f_replace(fluxo_processo.produto,'.',''),'-',''), tbitens.nomeitem, fluxo_processo.descroper,   fluxo_processo.seq, fluxo_processo.undoper, fluxo_processo.pchora, tipo, custo from
fluxo_processo left join tbitens on (produto = tbitens.codigoitem)
where custo = 1
order by fluxo_processo.produto, fluxo_processo.seq
;



/* View: ORDEM_DE_SERVICO */
CREATE VIEW ORDEM_DE_SERVICO(
    ID,
    USUARIO,
    CODIGO,
    NIVEL,
    NOME,
    SEQ,
    COMPONENTE,
    CONSUMO_UNIT,
    CONSUMO_TOT,
    SETOR,
    NOME_SETOR,
    PCS_HORA,
    SETUP_HORA,
    CARGA_HS,
    ARVORE,
    PRODUTO,
    NOME_PRODUTO,
    TIPO_EST,
    UND,
    LOTE,
    IDPROC,
    IDMAT,
    UND_POR,
    TIPOMP,
    CALCULO,
    VR_UNIT,
    CUSTO_MAT,
    CUSTO_TRAT,
    CUSTO_PROC_MAQ,
    CUSTO_PROC_MO,
    CUSTO_APOIO,
    CUSTO_ITEM,
    CUSTO_IMPORT_ITEM,
    CUSTO_ACUM,
    CONSUMO_EXEC,
    CONSUMO_CANC,
    CONSUMO_SALDO,
    CONSUMO_RES,
    CONSUMO_REQ,
    REQ_N,
    DATA_INICIO,
    DATA_TERMINO,
    CARGA_EXEC,
    CARGA_SALDO,
    OBS_MAT,
    OBS_PROC,
    N_OS,
    REC_1,
    REC_2,
    REC_3,
    CUSTO_OPER,
    CUSTO_OS,
    CUSTO_REAL,
    PEDCOMPRA_N,
    STATUS_OS,
    DATA_INC,
    DATA_LIB,
    DATA_PROD,
    DATA_FAT,
    TIPO_OS,
    PED_VENDA,
    ID_PED_VENDA,
    IDPAI,
    DATA_OS,
    CODIGO_CLIENTE,
    NOME_CLIENTE,
    PRODUTO_OS,
    QTDE_PRODUZIR,
    PRAZO_ENTREGA,
    TIPO,
    SALDO,
    TOTAL_PRODUZIDO,
    TOTAL_REJEITADO,
    TOTAL_FATURADO,
    TOTAL_LIBERADO,
    NOMEREC)
AS
select id, ESTRUT_OS.usuario, codigo, ESTRUT_OS.nivel, nome, seq, componente, consumo_unit, consumo_tot, setor, nome_setor, pcs_hora, setup_hora, carga_hs, arvore, estrut_os.produto, nome_produto, tipo_est, und, lote, idproc, idmat, und_por, tipomp, calculo, vr_unit, custo_mat, custo_trat, custo_proc_maq, custo_proc_mo, custo_apoio, custo_item, custo_import_item, custo_acum, consumo_exec, consumo_canc, consumo_saldo, consumo_res, consumo_req, req_n, data_inicio, data_termino, carga_exec, carga_saldo, obs_mat, obs_proc, n_os, rec_1, rec_2, rec_3, custo_oper, custo_os, custo_real, pedcompra_n, status_os, data_inc, data_lib, data_prod, data_fat, tipo_os, ped_venda, id_ped_venda, idpai,
 tb_os.data, tb_os.codigo_cliente, tb_os.nome_cliente, tb_os.produto, tb_os.qtde_produzir, tb_os.prazo_entrega, tb_os.tipo, tb_os.saldo, tb_os.total_produzido, tb_os.total_rejeitado, tb_os.total_faturado, tb_os.total_liberado,
 tbrecurso.nomerec
 from estrut_os join tb_os on (tb_os.numero_os = estrut_os.n_os) left join tbrecurso on (estrut_os.rec_1 = tbrecurso.idrec)  order by estrut_os.seq
;



/* View: ORDENS */
CREATE VIEW ORDENS(
    SITUACAO,
    NUMOF,
    PRODUTO,
    PROGRAMA,
    SEQ,
    CICLO,
    CICLO_MAQ,
    SETUP,
    NOME,
    ENTREGA,
    PRODUZIDO,
    PERDA,
    SALDO,
    TOLERANCIA,
    SETOR)
AS
select a.status, a.ordem, a.item, a.programa, a.seq, a.ciclo, a.ciclo_maq, a.setup, a.nome, a.entrega,
coalesce((select sum(b.qtde) from tb_eventos_os b where b.os = a.ordem and b.operacao='AT1' AND b.evento='PRODUCAO'),0),
coalesce((select sum(b.qtde) from tb_eventos_os b where b.os = a.ordem AND b.evento='REFUGO'),0),
(a.programa- coalesce((select sum(b.qtde) from tb_eventos_os b where b.os = a.ordem and b.operacao='AT1' AND b.evento='PRODUCAO'),0)),
case
when coalesce((select sum(b.qtde) from tb_eventos_os b where b.os = a.ordem and b.operacao='AT1' AND b.evento='PRODUCAO'),0) >=
cast(a.programa * 1.10 as integer)then 0
else
(cast(a.programa * 1.10 as integer))-
(coalesce((select sum(b.qtde) from tb_eventos_os b where b.os = a.ordem and b.operacao='AT1' AND b.evento='PRODUCAO'),0))
end, A.setor
from tb_of_ciclo a
;



/* View: OS_LOTES */
CREATE VIEW OS_LOTES(
    NUMERO_OS,
    DATA,
    PRODUTO,
    QTDE_PRODUZIR,
    TIPO,
    SALDO,
    TOTAL_PRODUZIDO,
    TOTAL_CANCELADO,
    LOTE,
    CODIGOITEM,
    QTDETOTAL,
    SALDOLOTE,
    ENTRADA,
    NAT,
    OS)
AS
select numero_os, data, produto, qtde_produzir, tb_os.tipo, saldo, total_produzido, total_cancelado,
lote, codigoitem, qtdetotal, saldolote, entrada, tblote.tipo, os
from tb_os left join tblote on (tb_os.numero_os = tblote.os) where tblote.tipo = 0
;



/* View: OS_MATERIAIS */
CREATE VIEW OS_MATERIAIS(
    TIPO_ITEM,
    CODIGOMAT,
    NOMEITEM,
    REFITEM,
    COMPRIMITEM,
    LARGURAITEM,
    ESPESSURAITEM,
    COD_PARAMETRO,
    OS,
    LOTE,
    QTDSAIDA,
    UND,
    IDPAI,
    ID,
    N_REC,
    N_SETOR,
    NOME_SETOR,
    N_OP,
    OS_ORIGEM,
    IDPROC,
    QTDE,
    TIPO,
    IDREC,
    IDSETOR,
    NOMEREC,
    NOMESETOR,
    OS_DESTINO)
AS
select a.tipo_item, a.codigomat, a.nomeitem, a.refitem, a.comprimitem, a.larguraitem, a.espessuraitem, a.cod_parametro, a.os, a.lote, a.qtdsaida, a.und, a.idpai, a.id, a.n_rec, a.n_setor, a.nome_setor, a.n_op, a.os_origem, a.idproc,
b.qtde, b.tipo, b.idrec, b.idsetor, b.nomerec, b.nomesetor, b.os_destino
from materiais_liberados a left join lote_endereco b on (a.lote = b.lote)
where qtdsaida > 0  order by idproc
;



/* View: PADRAO */
CREATE VIEW PADRAO(
    IDNUMPED,
    CODPROD,
    VLUNIT,
    STATUS)
AS
select idnumped, codprod, vlunit, status from tbpropitem
group by idnumped, codprod, vlunit, status order by codprod, idnumped
;



/* View: PLANO_CONTROLE */
CREATE VIEW PLANO_CONTROLE(
    IDARVPROC,
    IDARVMAT,
    ARVORE,
    PRODUTO,
    CODIGOITEM,
    COMPONENTE,
    SEQ,
    CALCULO,
    OBS,
    MNUM,
    QTDEOPER,
    SETOR,
    IDREC1,
    IDREC2,
    IDREC3,
    IDREC4,
    IDREC5,
    QTDESETUP,
    TEMPOPECA,
    SETPECA,
    TREAL,
    UNDOPER,
    MO,
    DESCROPER,
    VROPER,
    PCHORA,
    CODIGOPAI,
    PROXIMO,
    ANTERIOR,
    PIERCE,
    ROTEIRO,
    DIM_MINIMO,
    DIM_MAXIMO,
    ALTERACAO,
    USUARIO,
    ULTIMOCAMPO,
    PESOLIQ,
    VR_MAQ,
    VR_MO,
    VR_APOIO,
    TIPOSETOR,
    CUSTO,
    TIPO,
    NATUREZA_PLANO,
    ABREV_PLANO,
    DESENHO,
    NOME_PECA,
    NOME_CLIENTE,
    REV_DES,
    DATA_REV,
    DESC_REV,
    FALHA_ID,
    FALHA_IDFMEA,
    FALHA_CARACTERISTICA,
    FALHA_ITEM,
    FALHA_CARACT_ESP,
    FORMA_CONTROLE,
    TIPO_CARACTERISTICA,
    MINIMO,
    MAXIMO,
    UND_MED,
    MEIO_INSPECAO,
    RESOLUCAO,
    TAMANHO_AMOSTRA,
    UND_AMOSTRA,
    FREQUENCIA_AMOSTRA,
    UND_FREQ,
    METODO_CONTROLE,
    PLANO_REACAO,
    ID_FMEA,
    ID_PROC,
    ID_FALHA,
    STATUS_PROD,
    DESC_ITEM,
    COD_FAT)
AS
select idarvproc, idarvmat, fluxo_processo.arvore, fluxo_processo.produto, fluxo_processo.codigoitem, componente, fluxo_processo.seq, calculo, obs, mnum, qtdeoper, fluxo_processo.setor, idrec1, idrec2, idrec3, idrec4, idrec5, qtdesetup, tempopeca, setpeca, treal, undoper, mo, descroper, vroper, pchora, codigopai, proximo, anterior, pierce, roteiro, fluxo_processo.minimo, fluxo_processo.maximo, alteracao, fluxo_processo.usuario, ultimocampo, pesoliq, vr_maq, vr_mo, vr_apoio, tiposetor,
custo, tipo,
case tipo
when 1 then 'PROCESSO'
WHEN 2 THEN 'RECEBIMENTO'
WHEN 3 THEN 'PROCESSO'
WHEN 4 THEN 'FINAL'
when 0 then 'NA'
END,
case tipo
when 1 then 'IP'
WHEN 2 THEN 'IR'
WHEN 3 THEN 'IP'
WHEN 4 THEN 'IF'
WHEN 0 then 'NA'
END ,
TBITENS.desenhoitem, TBITENS.nomeitem, TBITENS.nomeclitem, TBITENS.revdesenhoitem, tbitens.datarevdes, tbrevdes.historico,
falha_id, falha_idfmea, falha_caracteristica, falha_item, falha_caract_esp, forma_controle, tipo_caracteristica, tb_plano.minimo, tb_plano.maximo, und_med, meio_inspecao, resolucao, tamanho_amostra, und_amostra, frequencia_amostra, und_freq, metodo_controle, plano_reacao, id_fmea, id_proc, id_falha,
case when
tb_fmea_info.tipo_fmea = 0 then 'PRODU��O'
WHEN tb_fmea_info.tipo_fmea = 1 then 'PROT�TIPO'
when tipo_fmea = 2 then 'PR�-LAN�AMENTO'
end, fluxo_processo.obs , TBITENS.codfaturamitem 
from fluxo_processo LEFT JOIN (TBITENS LEFT JOIN TBREVDES ON (TBITENS.revdesenhoitem = tbrevdes.revdes and tbitens.codigoitem = tbrevdes.codigoitem)) ON (fluxo_processo.produto = TBITENS.codigoitem)
left join (tb_plano LEFT JOIN tb_falha_fmea ON (tb_plano.id_falha  = tb_falha_fmea.falha_id)) on (fluxo_processo.idarvproc  = tb_plano.id_proc)
LEFT JOIN tb_fmea_info ON (fluxo_processo.produto = tb_fmea_info.produto)
;



/* View: PC */
CREATE VIEW PC(
    PC_NUM,
    PRODUTO,
    CODIGOITEM,
    DESCRICAO,
    TIPO_PC,
    OPERACAO,
    ID_PROC)
AS
select plano_controle.idarvproc, plano_controle.produto,
PLANO_CONTROLE.codigoitem
,
plano_controle.obs
, plano_controle.abrev_plano , plano_controle.descroper, plano_controle.id_proc
from plano_controle where plano_controle.abrev_plano  = 'IR' and plano_controle.idarvproc = plano_controle.id_proc 
group by plano_controle.idarvproc,  plano_controle.produto, plano_controle.codigoitem,
plano_controle.obs, plano_controle.abrev_plano , plano_controle.descroper, plano_controle.id_proc
having plano_controle.id_proc is not null
;



/* View: PC_OUT */
CREATE VIEW PC_OUT(
    PC_NUM,
    PRODUTO,
    CODIGOITEM,
    DESCRICAO,
    TIPO_PC,
    OPERACAO,
    ID_PROC)
AS
select plano_controle.idarvproc, plano_controle.produto,
PLANO_CONTROLE.codigoitem
,
plano_controle.obs
, plano_controle.abrev_plano , plano_controle.descroper, plano_controle.id_proc
from plano_controle where plano_controle.abrev_plano  = 'IR' and plano_controle.idarvproc <> plano_controle.id_proc
group by plano_controle.idarvproc,  plano_controle.produto, plano_controle.codigoitem,
plano_controle.obs, plano_controle.abrev_plano , plano_controle.descroper, plano_controle.id_proc
having plano_controle.id_proc is not null
;



/* View: PEDIDO_CENTROS */
CREATE VIEW PEDIDO_CENTROS(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    DESCONTOC,
    CFOPI,
    LIBENGEPED,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    UND,
    DESENHOITEM,
    REVDESENHOITEM,
    ET,
    SEMANA,
    ANOREF,
    APLICACAO,
    VTOTIPI,
    VORIPI,
    STPREV,
    MES,
    ULTIMA_NF,
    DATA_NF,
    QTD_NF,
    IE_ATRAZO,
    CC1,
    CC2,
    CC3,
    CC4,
    CC5)
AS
select
numped, codcli, fantasia, cpag, tbforender, tbforbairro, tbforcep, tbforcid, tbforest, tbforendercob, tbforbairrocob, tbforcepcob, tbforcidcob, tbforestcob, tbforenderent, tbforbairroent, tbforcepent, tbforcident, tbforestent, tbforcodtransp, tbfornometransp, tbpropc.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbpropc.icms, tbpropc.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, razao,descontoc,cfopi,libengeped,
iditem, idnumped, codprod, nomeprod, descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, ipi, saldo, vlfaturar, prazo, pcp, prazopcp, posicao, opnum, pedidocli,und, desenhoitem, revdesenhoitem, et, semana, anoref, aplicacao,
case (ipi*vlfaturar)
when 0 then 0 else
(ipi*vlfaturar)/100
end,
case (ipi*vlitem)
when 0 then 0 else
(ipi*vlitem)/100
end, tbpropitemc.status, upper(f_cmonthshortlang(prazo,'pt') || '/' || anoref),
ultima_nf, data_nf, qtd_nf, ie_atrazo, cc1, cc2, cc3, cc4, cc5
from tbpropc left join tbpropitemc  on (tbpropc.numped = tbpropitemc.idnumped)
;



/* View: PEDIDO_ET */
CREATE VIEW PEDIDO_ET(
    NUMPED,
    ET)
AS
select idnumped,et from tbpropitemc where et is not null group by idnumped,et
;



/* View: PEDIDO_PEND */
CREATE VIEW PEDIDO_PEND(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    NOMEITEM,
    CODIGOITEM,
    UNDUSOITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    ACABAMENTOITEM,
    SITTRIBITEM,
    CLASSFISCALITEM,
    FCVENDA,
    COMPLEMENTO,
    CFOPI,
    SEMANA,
    SEMANAPCP,
    ANOREF,
    STPREV,
    NFSAIDA,
    DESCONTOC,
    MESBASE,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    UNIDADE)
AS
select
numped, codcli, fantasia, cpag, d.tbforender, d.tbforbairro, d.tbforcep, d.tbforcid, d.tbforest, d.tbforendercob, d.tbforbairrocob, d.tbforcepcob, d.tbforcidcob, d.tbforestcob, a.tbforenderent, a.tbforbairroent, a.tbforcepent, a.tbforcident, a.tbforestent, a.tbforcodtransp, a.tbfornometransp, a.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbicms.aliqpjcont, a.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, razao,
iditem, idnumped, b.codprod  , nomeprod, descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, ipi, saldo, vlfaturar, prazo, pcp, prazopcp, posicao, opnum, pedidocli,nomeitem,codigoitem,und, b.desenhoitem, b.revdesenhoitem,acabamentoitem, sittribitem, c.classfiscalitem,fcvenda, b.complemento, cfopi, semanaven, semanapcp, anoref, b.status , '*',0,
f_month(prazo), codigo_municipio, codigo_uf, endereco_numero, d.complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob, a.unidade
from tbprop a left join (tbpropitem b left join tbitens c on (b.codprod = c.codigoitem)) on (a.numped = b.idnumped) left join tbfor d on (a.codcli = d.tbforcod) left join tbicms on (d.tbforest = tbicms.uf_icms) where a.status = 4
;



/* View: PEDIDO_PEND2 */
CREATE VIEW PEDIDO_PEND2(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    CFOPI,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    UNIDADE)
AS
select
numped, codcli, tbfor.tbforfan,  cpag, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest, tbfor.tbforendercob, tbfor.tbforbairrocob, tbfor.tbforcepcob, tbfor.tbforcidcob, tbfor.tbforestcob, tbfor.tbforenderent, tbfor.tbforbairroent, tbfor.tbforcepent, tbfor.tbforcident, tbfor.tbforestent, tbprop.tbforcodtransp, tbprop.tbfornometransp, tbprop.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbprop.icms, tbprop.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, tbfor.tbforraz,cfopi,
codigo_municipio, codigo_uf, endereco_numero, tbfor.complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob, tbprop.unidade
from tbprop left join tbfor on (tbprop.codcli = tbfor.tbforcod) where  tbprop.status = 4
;



/* View: PEDIDO_PEND3 */
CREATE VIEW PEDIDO_PEND3(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    NOMEITEM,
    CODIGOITEM,
    UNDUSOITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    ACABAMENTOITEM,
    SITTRIBITEM,
    CLASSFISCALITEM,
    FCVENDA,
    COMPLEMENTO,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB,
    UNIDADE)
AS
select
numped, codcli, tbfor.tbforfan , cpag, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest, tbfor.tbforendercob, tbfor.tbforbairrocob, tbfor.tbforcepcob, tbfor.tbforcidcob, tbfor.tbforestcob, tbfor.tbforenderent, tbfor.tbforbairroent, tbfor.tbforcepent, tbfor.tbforcident, tbfor.tbforestent, tbprop.tbforcodtransp, tbprop.tbfornometransp, tbprop.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbprop.icms, tbprop.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, tbfor.tbforraz,
iditem, idnumped, tbpropitem.codprod  , nomeprod, descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, ipi, saldo, vlfaturar, prazo, pcp, prazopcp, posicao, opnum, pedidocli,nomeitem,codigoitem,undvenda, tbpropitem.desenhoitem, tbpropitem.revdesenhoitem,acabamentoitem,sittribitem, classfiscalitem, fcvenda, tbpropitem.complemento,
codigo_municipio, codigo_uf, endereco_numero, tbfor.complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob, tbprop.unidade 
from tbprop left join (tbpropitem left join tbitens on (tbpropitem.codprod = tbitens.codigoitem)) on (tbprop.numped = tbpropitem.idnumped)
left join tbfor on (tbprop.codcli = tbfor.tbforcod)
where tbprop.status >= 3
;



/* View: PEDIDO_PENDC */
CREATE VIEW PEDIDO_PENDC(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    NFSAIDA,
    DESCONTOC,
    CFOPI,
    LIBENGEPED,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    SEMANA,
    ANOREF,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    NOMEITEM,
    CODIGOITEM,
    UNDUSOITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    ACABAMENTOITEM,
    SITTRIBITEM,
    CLASSFISCALITEM,
    STPREV,
    FCVENDA,
    COMPLEMENTO,
    INSPECAO,
    PROJETO,
    UNIDADE,
    CODIGO_MUNICIPIO,
    CODIGO_UF,
    ENDERECO_NUMERO,
    END_COMPLEMENTO,
    CODIGO_MUNICIPIO_ENT,
    CODIGO_UF_ENT,
    ENDERECO_NUMERO_ENT,
    COMPLEMENTO_ENT,
    CODIGO_MUNICIPIO_COB,
    CODIGO_UF_COB,
    ENDERECO_NUMERO_COB,
    COMPLEMENTO_COB)
AS
select
numped, codcli, fantasia, cpag, tbfor.tbforender, tbfor.tbforbairro, tbfor.tbforcep, tbfor.tbforcid, tbfor.tbforest, tbfor.tbforendercob, tbfor.tbforbairrocob, tbfor.tbforcepcob, tbfor.tbforcidcob, tbfor.tbforestcob, tbfor.tbforenderent, tbfor.tbforbairroent, tbfor.tbforcepent, tbfor.tbforcident, tbfor.tbforestent, tbfor.tbforcodtransp, tbfor.tbfornometransp, tbpropc.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbpropc.icms, tbpropc.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, razao,nfsaida,descontoc,cfopi,libengeped,
iditem, idnumped, tbpropitemc.codprod  , nomeprod, descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, ipi, saldo, vlfaturar, prazo, pcp, semana, anoref, prazopcp, posicao, opnum, pedidocli,nomeitem,codigoitem,tbpropitemc.und , tbpropitemc.desenhoitem, tbpropitemc.revdesenhoitem,acabamentoitem,sittribitem, tbitens.classfiscalitem, tbpropitemc.status,
CASE tbpropitemc.und 
when 'KG' THEN TBITENS.pesoliqitem
ELSE TBITENS.fatorconvitem 
end, f_left4(tbpropitemc.descorcam,100),
case
when tbpropc.libengeped = 0 then 'LS'
when tbpropc.libengeped = 1 then 'AI'
end , TBPROPC.formaenv, tbpropc.unidade, codigo_municipio, codigo_uf, endereco_numero, tbfor.complemento, codigo_municipio_ent, codigo_uf_ent, endereco_numero_ent, complemento_ent, codigo_municipio_cob, codigo_uf_cob, endereco_numero_cob, complemento_cob
from tbpropc left join (tbpropitemc left join tbitens on (tbpropitemc.codprod = tbitens.codigoitem)) on (tbpropc.numped = tbpropitemc.idnumped) left join tbfor on (tbpropc.codcli = tbfor.tbforcod) where tbpropc.status = 4 and tbpropitemc.status = 0
;



/* View: PEDIDO_PENDC2 */
CREATE VIEW PEDIDO_PENDC2(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    NFSAIDA,
    DESCONTOC,
    CFOPI,
    LIBENGEPED,
    UNIDADE)
AS
select
numped, codcli, fantasia, cpag, tbforender, tbforbairro, tbforcep, tbforcid, tbforest, tbforendercob, tbforbairrocob, tbforcepcob, tbforcidcob, tbforestcob, tbforenderent, tbforbairroent, tbforcepent, tbforcident, tbforestent, tbforcodtransp, tbfornometransp, tbpropc.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbpropc.icms, tbpropc.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, razao, nfsaida, descontoc,cfopi,libengeped, tbpropc.unidade 
from tbpropc where tbpropc.status = 4
;



/* View: PEDIDO_PENDC3 */
CREATE VIEW PEDIDO_PENDC3(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    TBFORENDER,
    TBFORBAIRRO,
    TBFORCEP,
    TBFORCID,
    TBFOREST,
    TBFORENDERCOB,
    TBFORBAIRROCOB,
    TBFORCEPCOB,
    TBFORCIDCOB,
    TBFORESTCOB,
    TBFORENDERENT,
    TBFORBAIRROENT,
    TBFORCEPENT,
    TBFORCIDENT,
    TBFORESTENT,
    TBFORCODTRANSP,
    TBFORNOMETRANSP,
    ST,
    CFOP,
    DESCCFOP,
    COMISSAOVEN,
    COMISSAOREP,
    COMISSAOINT,
    COMISSAOEXT,
    OBSPED,
    ENTRADA,
    IMP,
    TFP,
    CONTATO,
    APROVACAO,
    VEND,
    NOMEVEND,
    IMPOSTOS,
    PRAZOCOT,
    VALIDADECOT,
    PRIPED,
    OBSCOT,
    DEPARTAM,
    RAZAO,
    DESCONTOC,
    CFOPI,
    LIBENGEPED,
    IDITEM,
    IDNUMPED,
    CODPROD,
    NOMEPROD,
    DESCORCAM,
    QTDEPED,
    QTDEENT,
    QTDECANC,
    VLUNIT,
    VLITEM,
    IPI,
    SALDO,
    VLFATURAR,
    PRAZO,
    PCP,
    PRAZOPCP,
    POSICAO,
    OPNUM,
    PEDIDOCLI,
    NOMEITEM,
    CODIGOITEM,
    UNDUSOITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    ACABAMENTOITEM,
    SITTRIBITEM,
    CLASSFISCALITEM,
    STPREV,
    UNIDADE)
AS
select
numped, codcli, fantasia, cpag, tbforender, tbforbairro, tbforcep, tbforcid, tbforest, tbforendercob, tbforbairrocob, tbforcepcob, tbforcidcob, tbforestcob, tbforenderent, tbforbairroent, tbforcepent, tbforcident, tbforestent, tbforcodtransp, tbfornometransp, tbpropc.status, cfop, desccfop, comissaoven, comissaorep, comissaoint, comissaoext, obsped, entrada, tbpropc.icms, tbpropc.tf,contato,aprovacao,
vend, nomevend, impostos, prazocot, validadecot, priped, obscot, departam, razao,descontoc,cfopi,libengeped,
iditem, idnumped, tbpropitemc.codprod  , nomeprod, descorcam, qtdeped, qtdeent, qtdecanc, vlunit, vlitem, ipi, saldo, vlfaturar, prazo, pcp, prazopcp, posicao, opnum, pedidocli,nomeitem,codigoitem,undusoitem, tbpropitemc.desenhoitem, tbpropitemc.revdesenhoitem,acabamentoitem,sittribitem, classfiscalitem, tbpropitemc.status, tbpropc.unidade 
from tbpropc left join (tbpropitemc left join tbitens on (tbpropitemc.codprod = tbitens.codigoitem)) on (tbpropc.numped = tbpropitemc.idnumped) where tbpropc.status = 4
;



/* View: PEDIDOS_ALL_CC */
CREATE VIEW PEDIDOS_ALL_CC(
    NUMPED,
    IDITEMPED,
    CODIGO,
    QTDE,
    VALOR_TOTAL,
    NCC)
AS
select pedido_centros.numped, pedido_centros.iditem,
pedido_centros.codprod, pedido_centros.qtdeped,
pedido_centros.vlitem,
pedido_centros.cc1 from pedido_centros union all
select pedido_centros.numped, pedido_centros.iditem,
pedido_centros.codprod, pedido_centros.qtdeped,
pedido_centros.vlitem,
pedido_centros.cc2 from pedido_centros union all
select pedido_centros.numped, pedido_centros.iditem,
pedido_centros.codprod, pedido_centros.qtdeped,
pedido_centros.vlitem,
pedido_centros.cc3 from pedido_centros union all
select pedido_centros.numped, pedido_centros.iditem,
pedido_centros.codprod, pedido_centros.qtdeped,
pedido_centros.vlitem,
pedido_centros.cc4 from pedido_centros union all
select pedido_centros.numped, pedido_centros.iditem,
pedido_centros.codprod, pedido_centros.qtdeped,
pedido_centros.vlitem,
pedido_centros.cc5 from pedido_centros
;



/* View: PEDIDOS_CC */
CREATE VIEW PEDIDOS_CC(
    NUMPED,
    IDITEMPED,
    CODIGO,
    QTDE,
    VALOR_TOTAL,
    NCC,
    TOTAL_CC)
AS
select  numped, iditemped, codigo, qtde, valor_total, ncc, count(iditemped) from pedidos_all_cc
where ncc is not null and ncc <> 0
group by numped, iditemped, codigo, qtde, valor_total, ncc
;



/* View: PERDAS_QUALIDADE */
CREATE VIEW PERDAS_QUALIDADE(
    DATA_INSPECAO,
    CODIGO,
    CONSEQUENCIA,
    DISPOSICAO,
    LAUDO,
    CONTROLE,
    SCRAP,
    REPROVADO,
    QTDE,
    VALOR_SUCATA,
    VALOR_REPROVADO)
AS
SELECT a.data_inspecao, a.codigo, a.consequencia, a.disposicao, a.laudo, a.controle, a.scrap, a.reprovado, a.total ,
a.valor_sucata, a.valor_reprovado
 FROM apontamentos_valor a where CONTROLE > 0 AND (a.scrap + a.reprovado) > 0
GROUP BY
a.data_inspecao, a.codigo, a.consequencia, a.disposicao, a.laudo, a.controle, a.scrap, a.reprovado, a.total,
a.valor_sucata, a.valor_reprovado
order by a.controle
;



/* View: PERMISSAO_USER */
CREATE VIEW PERMISSAO_USER(
    ID_REGISTRO,
    ID_USUARIO,
    ID_PERMISSAO,
    NIVEL,
    ID_COD,
    PERMNOME,
    PERMMODULO)
AS
select id_registro, id_usuario, id_permissao, nivel, id_cod,
permnome, permmodulo from tb_perm_user join tb_perm_padrao
on id_permissao = permid order by id_registro
;



/* View: PERMISSOES_NOVAS */
CREATE VIEW PERMISSOES_NOVAS(
    PERMID,
    PERMNOME,
    ID_PERMISSAO,
    USERID)
AS
WITH
GROUP_RULE
AS
(
SELECT
A.userid,
B.id_permissao
FROM
TB_USER A LEFT JOIN tb_perm_user B ON (A.userid = B.id_usuario))
SELECT G1.permid, G1.permnome, G2.ID_PERMISSAO, G2.USERID FROM tb_perm_padrao G1
LEFT JOIN
GROUP_RULE G2
 ON (G1.permid = G2.ID_PERMISSAO)
;



/* View: PESAGEM */
CREATE VIEW PESAGEM(
    MES,
    VALOR)
AS
select f_cmonthshortlang(a.data,'PT'), sum(a.valor_lote) from apontamentos_valor a
where a.data between '01.08.2015' and '31.08.2015'
group by f_cmonthshortlang(a.data,'PT')
;



/* View: PLANILHA_CUSTO */
CREATE VIEW PLANILHA_CUSTO(
    COD_DESENHO,
    COD_FATURAM,
    DESCRICAO,
    COD_INTERNO,
    LOTE,
    MATERIAIS,
    TRATAMENTO,
    PROCESSO,
    TOTAL,
    ARVORE,
    CLIENTE,
    CODCLI)
AS
select cod_desenho, cod_faturam, descarvore, produto, lote, vrarvmat, vrarvtrat, vrarvoper, vrarvtot,
TBARVORE.arvore , cliente, codcli
from tbarvore
;



/* View: PLANO_CONTAS */
CREATE VIEW PLANO_CONTAS(
    GRUPOCONTAB,
    DESCCONTAB,
    REDUZIDA)
AS
select grupocontab, desccontab, reduzida from tbcontab
where reduzida > 0
;



/* View: PLANO_CONTAS2 */
CREATE VIEW PLANO_CONTAS2(
    GRUPOCONTAB,
    DESCCONTAB,
    REDUZIDA)
AS
select grupocontab, desccontab, reduzida from tbcontab2
where reduzida > 0
;



/* View: PLANO_CONTROLE_NOVO */
CREATE VIEW PLANO_CONTROLE_NOVO(
    IDARVPROC,
    PRODUTO,
    CODIGOITEM,
    COMPONENTE,
    SEQ,
    DESCROPER,
    DIM_MINIMO,
    DIM_MAXIMO,
    TIPOSETOR,
    CUSTO,
    TIPO,
    NATUREZA_PLANO,
    ABREV_PLANO,
    DESENHO,
    NOME_PECA,
    NOME_CLIENTE,
    REV_DES,
    DATA_REV,
    DESC_REV,
    FALHA_CARACTERISTICA,
    FALHA_ITEM,
    FALHA_CARACT_ESP,
    FORMA_CONTROLE,
    TIPO_CARACTERISTICA,
    MINIMO,
    MAXIMO,
    UND_MED,
    MEIO_INSPECAO,
    RESOLUCAO,
    TAMANHO_AMOSTRA,
    UND_AMOSTRA,
    FREQUENCIA_AMOSTRA,
    UND_FREQ,
    METODO_CONTROLE,
    PLANO_REACAO,
    ID_PROC,
    STATUS_PROD,
    DESC_ITEM,
    COD_FAT)
AS
select a.idarvproc, a.produto, a.codigoitem, a.componente, a.seq, descroper, a.minimo, a.maximo, tiposetor,
b.custo, b.tipo,
case b.tipo
when 1 then 'PROCESSO'
WHEN 2 THEN 'RECEBIMENTO'
WHEN 3 THEN 'PROCESSO'
WHEN 4 THEN 'FINAL'
when 0 then 'NA'
END,
case b.tipo
when 1 then 'IP'
WHEN 2 THEN 'IR'
WHEN 3 THEN 'IP'
WHEN 4 THEN 'IF'
WHEN 0 then 'NA'
END ,
TBITENS.desenhoitem, TBITENS.nomeitem, TBITENS.nomeclitem, TBITENS.revdesenhoitem, tbitens.datarevdes, tbrevdes.historico,
falha_caracteristica, falha_item, falha_caract_esp, forma_controle, tipo_caracteristica, tb_plano.minimo, tb_plano.maximo, und_med, meio_inspecao, resolucao, tamanho_amostra, und_amostra, frequencia_amostra, und_freq, metodo_controle, plano_reacao, id_proc,
case when
tb_fmea_info.tipo_fmea = 0 then 'PRODU��O'
WHEN tb_fmea_info.tipo_fmea = 1 then 'PROT�TIPO'
when tipo_fmea = 2 then 'PR�-LAN�AMENTO'
end, a.obs , TBITENS.codfaturamitem
from tbarvoreproc a LEFT JOIN (TBITENS LEFT JOIN TBREVDES ON (TBITENS.revdesenhoitem = tbrevdes.revdes and tbitens.codigoitem = tbrevdes.codigoitem)) ON (a.produto = TBITENS.codigoitem)
left join (tb_plano LEFT JOIN tb_falha_fmea ON (tb_plano.id_falha  = tb_falha_fmea.falha_id)) on (a.idarvproc  = tb_plano.id_proc)
LEFT JOIN tb_fmea_info ON (a.produto = tb_fmea_info.produto)
left join tb_atividade b on (a.mnum = b.id)
;



/* View: PLANO_CONTROLE3 */
CREATE VIEW PLANO_CONTROLE3(
    FALHA_ID,
    FALHA_IDFMEA,
    FALHA_CARACTERISTICA,
    FALHA_ITEM,
    FALHA_CARACT_ESP,
    FORMA_CONTROLE,
    TIPO_CARACTERISTICA,
    MINIMO,
    MAXIMO,
    UND_MED,
    MEIO_INSPECAO,
    RESOLUCAO,
    TAMANHO_AMOSTRA,
    UND_AMOSTRA,
    FREQUENCIA_AMOSTRA,
    UND_FREQ,
    METODO_CONTROLE,
    PLANO_REACAO,
    ID_FMEA,
    ID_PROC,
    ID_FALHA)
AS
select
falha_id, falha_idfmea, falha_caracteristica, falha_item, falha_caract_esp, forma_controle,
tipo_caracteristica, tb_plano.minimo, tb_plano.maximo, und_med, meio_inspecao, resolucao,
tamanho_amostra, und_amostra, frequencia_amostra, und_freq, metodo_controle, plano_reacao,
id_fmea, id_proc, id_falha
from
tb_plano join tb_falha_fmea ON (tb_plano.id_fmea = tb_falha_fmea.falha_idfmea and tb_plano.id_falha = tb_falha_fmea.falha_id)
;



/* View: PLANO_ENTREGA_MENSAL */
CREATE VIEW PLANO_ENTREGA_MENSAL(
    MES,
    ANO,
    CODPROD,
    NOMEITEM,
    TIPO_ITEM,
    QTD_DEMANDA,
    ANOMES)
AS
select f_month(tbpropitemc.prazo),f_year(tbpropitemc.prazo),    tbpropitemc.codprod ,tbitens.nomeitem ,tbitens.tipoitem ,  sum(tbpropitemc.saldo * tbitens.fatorconvitem), tbpropitemc.anoref || f_padleft(F_MONTH(tbpropitemc.prazo),'0',2)
from tbpropitemc left join tbitens on (tbpropitemc.codprod = codigoitem) where tbpropitemc.saldo > 0 and PRAZO >='01.01.2011' and tbpropitemc.status = 0 AND ANOREF >= '2011'
and tbitens.tipoitem in ('MAT�RIA-PRIMA','COMPONENTE COMPRADO')
group by f_month(tbpropitemc.prazo),f_year(tbpropitemc.prazo),tbpropitemc.codprod, TBITENS.nomeitem, tbitens.tipoitem, anoref || f_padleft(F_MONTH(tbpropitemc.prazo),'0',2)
order by tbpropitemc.CODPROD, tbpropitemc.anoref || f_padleft(F_MONTH(tbpropitemc.prazo),'0',2)
;



/* View: PRECO_ET */
CREATE VIEW PRECO_ET(
    SISTEMA,
    FANTASIA,
    PEDIDOCLI,
    IDNUMNF,
    IDITEMNF,
    IDITEMPED,
    CODIGOITEM,
    DESCRICAO,
    QTDEITEM,
    PRECO,
    UNID,
    IDITEM,
    IDNUMPED,
    N_ET,
    TIPO,
    COD_ET)
AS
select tbnfc.sistema, tbnfc.fantasia, tbnfc.pedidocli,idnumnf,  iditemnf, iditemped, codigoitem, descricao, qtdeitem, tbitensnfc.vlunit , tbitensnfc.und,
iditem, idnumped, tbpropitemc.et, tbet.tipo, 'ET' || tbpropitemc.et ||'/'||tbet.tipo from tbnfc join tbitensnfc join tbpropitemc join tbet on (tbpropitemc.et = tbet.et) on (iditemped = iditem)
on (tbnfc.numnf = tbitensnfc.idnumnf)
where tbet.tipo like 'T%'
order by tbpropitemc.et, iditemnf desc
;



/* View: PRECO_MEDIO_ITENS */
CREATE VIEW PRECO_MEDIO_ITENS(
    CODIGOITEM,
    NOMEITEM,
    UNDCOMPRAITEM,
    UNDUSOITEM,
    FATORCONVITEM,
    GRUPOITEM,
    PRECOCOMPRA,
    VALORCUSTOITEM,
    VALORMEDIOITEM,
    REVCUSTO,
    USERCUSTO,
    REFCUSTO,
    ULTFORN)
AS
select
codigoitem, nomeitem, undcompraitem, undusoitem, fatorconvitem, grupoitem,
precocompra, valorcustoitem,
valormedioitem,
    revcusto,usercusto,
          refcusto,ultforn
from tbitens where grupoitem in('01','04','11','18')
;



/* View: PREV_PED */
CREATE VIEW PREV_PED(
    CODCLI,
    FANTASIA,
    ST,
    CFOP,
    DESCCFOP,
    VPED,
    VIPI,
    VICMS,
    ANOREF,
    STPREV,
    MESBASE,
    CFOPI)
AS
select
codcli, fantasia,
st, cfop, desccfop,
sum(vlitem),sum(pedido.voripi), sum(pedido.vlicms), anoref, stprev, mesbase, cfopi
 from pedido group by codcli, fantasia,
st, cfop, desccfop,
anoref, stprev, mesbase, cfopi having (pedido.st = 4) and (stprev in(0,2)) and (cfop in('5.101','6.101','7.101','5.122','6.122','7.122','5.917','5.111'))
;



/* View: PREV_PED_MES */
CREATE VIEW PREV_PED_MES(
    CODCLI,
    FANTASIA,
    PREVISAO,
    PREVISAO_IPI,
    PREVISAO_ICMS,
    MESBASE)
AS
select codcli,fantasia, sum(vped),sum(vipi),sum(vicms), mesbase from prev_ped
group by codcli,fantasia, mesbase
;



/* View: PREV_PED_POR_PRAZO */
CREATE VIEW PREV_PED_POR_PRAZO(
    CODCLI,
    FANTASIA,
    ST,
    CFOP,
    DESCCFOP,
    VPED,
    VIPI,
    VICMS,
    ANOREF,
    STPREV,
    PRAZO,
    MESBASE,
    CFOPI)
AS
select
codcli, fantasia,
st, cfop, desccfop,
sum(vlitem),sum(pedido.voripi), sum(pedido.vlicms), anoref, stprev, prazo, mesbase, cfopi
 from pedido group by codcli, fantasia,
st, cfop, desccfop,
anoref, stprev, prazo, mesbase, cfopi having (pedido.st = 4) and (stprev in(0,2)) and (cfop in('5.101','6.101','7.101','5.122','6.122','7.122','5.917','5.111'))
;



/* View: PREV_PED_POR_PRAZO_PRODUTO */
CREATE VIEW PREV_PED_POR_PRAZO_PRODUTO(
    CODCLI,
    FANTASIA,
    ST,
    CFOP,
    DESCCFOP,
    VPED,
    VIPI,
    VICMS,
    ANOREF,
    STPREV,
    PRAZO,
    PRODUTO,
    QTDE,
    SALDO,
    SEMANA,
    MESBASE,
    ANOMES,
    CFOPI,
    DD,
    MM,
    AA,
    CRITICO,
    DESENHOITEM)
AS
select
codcli, fantasia,
st, cfop, desccfop,
sum(pedido.vlfaturar) ,sum(pedido.voripi), sum(pedido.vlicms), anoref, stprev, prazo,CODPROD,SUM(PEDIDO.qtdeped), SUM(PEDIDO.saldo), SEMANA, mesbase, f_right(mesbase, 4)||f_left(mesbase, 2), cfopi, f_padleft(f_dayofmonth(PRAZO),'0',2), f_padleft(f_MONTH(PRAZO),'0',2), f_right(ANOREF,2),
PEDIDO.critico, desenhoitem
from pedido group by codcli, fantasia, PEDIDO.prazo, PEDIDO.codprod, semana,
st, cfop, desccfop,
anoref, stprev,mesbase, f_right(mesbase, 4)||f_left(mesbase, 2), cfopi, f_padleft(f_dayofmonth(PRAZO),'0',2), f_padleft(f_MONTH(PRAZO),'0',2), f_right(ANOREF,2), CRITICO, desenhoitem  having (pedido.st = 4) and (cfop in('5.101','6.101','7.101','5.122','6.122','7.122','5.917','5.111'))
;



/* View: PROCESSO_ADI */
CREATE VIEW PROCESSO_ADI(
    COD,
    N_OP,
    DESC_OP,
    PC_HORA,
    EQUIP,
    NOME_MAQ,
    N_MAQ,
    ORIGEM)
AS
select f_replace(f_replace(tbarvoreproc.produto,'.',''),'-',''),
tbarvoreproc.seq, tbarvoreproc.descroper,
tbarvoreproc.pchora, tbarvoreproc.idrec1,
tbrecurso.nomerec, '', 'ADI'
from TBARVOREPROC LEFT JOIN TBRECURSO ON IDREC1 = TBRECURSO.idrec 
ORDER BY f_replace(f_replace(tbarvoreproc.produto,'.',''),'-',''), SEQ
;



/* View: PRODT */
CREATE VIEW PRODT(
    IDC,
    CODIGOITEM,
    NOMEITEM,
    UND,
    SIT,
    TIPOR)
AS
select '"1"'as idc, '"'||codigoitem||'"', '"'||nomeitem||'"', '"'||undcompraitem||'"',
'"000"' as sit, '"P"' as tipor
from tbitens where f_left(codigoitem,2)='11' and f_stringlength(codigoitem)=15 order by codigoitem
;



/* View: PRODUCAO */
CREATE VIEW PRODUCAO(
    ID,
    LANCAMENTO,
    DATA,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    QUANTIDADE,
    INICIO,
    FIM,
    CODIGO,
    PARADA,
    DESCRICAO,
    STATUS,
    TEMPO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR)
AS
select a.id, a.lancamento, a.data, a.operador, a.turno, a.ordem, a.operacao, a.maquina, a.quantidade, a.inicio, a.fim, a.codigo,
b.parada, b.descricao, b.status,
a.tempo  ,   c.nome_maquina, c.setor, c.nome_setor
from tb_apontamento a
left join
tb_motivos_parada b on (a.lancamento = b.parada)
left join recursos c on (a.maquina = c.maquina)
where a.lancamento < 30
;



/* View: PRODUCAO_PARADAS */
CREATE VIEW PRODUCAO_PARADAS(
    LANCAMENTO,
    MES,
    ANO,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    QUANTIDADE,
    CODIGO,
    PARADA,
    DESCRICAO,
    STATUS,
    TEMPO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    DISP_TURNO,
    HS_PARADAS,
    HS_TRAB,
    DISP_DIA,
    DISP_MES)
AS
select a.lancamento,
f_month(a.data),
f_year(a.data),
a.operador,
a.turno,
a.ordem,
a.operacao,
a.maquina,
a.quantidade,
a.codigo,
b.parada,
b.descricao,
b.status,
sum(a.tempo),
c.nome_maquina,
c.grupo,
c.nome_grupo,
/* Disp por Turno */
case
when turno = 1 then c.capt1
when turno = 2 then c.capt2
when turno = 3 then c.capt3
end,
/* Horas Paradas */
case A.LANCAMENTO
WHEN 1 THEN 0
ELSE SUM(TEMPO)
END,
/* Horas  Trabalhadas */
case
WHEN A.LANCAMENTO<>1
THEN 0
ELSE SUM(TEMPO-1)
END,

CASE 
A.LANCAMENTO
WHEN 1 THEN
c.captotdia
ELSE 0 END,



c.captdisp

from tb_apontamento a
left join
tb_motivos_parada b on (a.lancamento = b.parada)
left join setores c on (a.maquina = c.maquina)
where a.lancamento < 30
group by
a.lancamento, f_month(a.data), f_year(a.data), a.operador, a.turno, a.ordem, a.operacao, a.maquina, a.quantidade, a.codigo,
b.parada, b.descricao, b.status,
c.nome_maquina, c.grupo, c.nome_grupo,
case
when turno = 1 then c.capt1
when turno = 2 then c.capt2
when turno = 3 then c.capt3
end, c.captotdia, c.captdisp
order by a.maquina, a.turno
;



/* View: PRODUCAO_PARADAS_DIA */
CREATE VIEW PRODUCAO_PARADAS_DIA(
    LANCAMENTO,
    MES,
    ANO,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    QUANTIDADE,
    CODIGO,
    PARADA,
    DESCRICAO,
    STATUS,
    TEMPO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    DISP_TURNO,
    HS_PARADAS,
    HS_TRAB,
    DISP_DIA,
    DISP_MES,
    DIA)
AS
select a.lancamento, f_month(a.data), f_year(a.data), a.operador, a.turno, a.ordem, a.operacao, a.maquina, a.quantidade, a.codigo,
b.parada, b.descricao, b.status,
sum(a.tempo)  ,   c.nome_maquina, c.grupo, c.nome_grupo,
case
when turno = 1 then c.capt1
when turno = 2 then c.capt2
when turno = 3 then c.capt3
end,
case A.LANCAMENTO
WHEN 1 THEN 0
ELSE SUM(TEMPO)
END,
case
WHEN A.LANCAMENTO<>1
THEN 0
ELSE SUM(TEMPO-1)
END, c.captotdia, c.captdisp, a.data
from tb_apontamento a
left join
tb_motivos_parada b on (a.lancamento = b.parada)
left join setores c on (a.maquina = c.maquina)
where a.lancamento < 30
group by
a.lancamento, f_month(a.data), f_year(a.data), a.operador, a.turno, a.ordem, a.operacao, a.maquina, a.quantidade, a.codigo,
b.parada, b.descricao, b.status,
c.nome_maquina, c.grupo, c.nome_grupo,
case
when turno = 1 then c.capt1
when turno = 2 then c.capt2
when turno = 3 then c.capt3
end, c.captotdia, c.captdisp, a.data
order by a.maquina, a.turno
;



/* View: PRODUCAO_PECAS */
CREATE VIEW PRODUCAO_PECAS(
    LANCAMENTO,
    DATA,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    PRODUZIDO,
    REFUGO,
    INICIO,
    FIM,
    CODIGO,
    PARADA,
    DESCRICAO,
    STATUS,
    TEMPO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    MES,
    ANO)
AS
select a.lancamento, a.data, a.operador, a.turno, a.ordem, a.operacao, a.maquina, a.quantidade, 0, a.inicio, a.fim, a.codigo,
b.parada,


case when
b.descricao = 'HORAS TRABALHADAS' THEN 'PECAS PRODUZIDAS'
ELSE B.descricao
END, b.status,
a.tempo  ,   c.nome_maquina, c.setor, c.nome_setor, f_month(a.data), f_year(a.data)
from tb_apontamento a
left join
tb_motivos_parada b on (a.lancamento = b.parada)
left join setores c on (a.maquina = c.maquina)
where a.lancamento = 1
;



/* View: PRODUCAO_PERDAS */
CREATE VIEW PRODUCAO_PERDAS(
    LANCAMENTO,
    DATA,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    PRODUZIDO,
    REFUGO,
    INICIO,
    FIM,
    CODIGO,
    PARADA,
    DESCRICAO,
    STATUS,
    TEMPO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    MES,
    ANO)
AS
select a.lancamento, a.data, a.operador, a.turno, a.ordem, a.operacao, a.maquina, 0, a.quantidade, a.inicio, a.fim, a.codigo,
b.parada,


case when
b.descricao = 'HORAS TRABALHADAS' THEN 'PECAS PRODUZIDAS'
ELSE B.descricao
END, b.status,
a.tempo  ,   c.nome_maquina, c.setor, c.nome_setor, F_month(a.data), f_year(a.data)
from tb_apontamento a
left join
tb_motivos_parada b on (a.lancamento = b.parada)
left join setores c on (a.maquina = c.maquina)
where a.lancamento >=30
;



/* View: VW_SETORES */
CREATE VIEW VW_SETORES(
    GRUPO,
    NOME_GRUPO,
    MAQUINA,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    NCC,
    CAPTOTDIA,
    CAPTOTMES,
    CAPT1,
    CAPT2,
    CAPT3,
    CAPTDISP,
    TIPO,
    ANO_SOLIC,
    MES_OM,
    MES_ANO,
    REF_MAQ,
    DT_POSICAO)
AS
select c.idccusto, c.nome, a.idrec, a.nomerec, b.idsetor, b.nomesetor, b.ncc, a.capdisp,
((a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs))*a.dias_disp_mes,

a.t1realhs, a.t2realhs, a.t3realhs ,

((a.t1capqtd * a.t1caphs)+
(a.t2capqtd * a.t2caphs)+
(a.t3capqtd * a.t3caphs))*a.dias_tot_mes, c.tipomo,
EXTRACT(YEAR FROM A.dt_posicao),
EXTRACT(MONTH FROM A.dt_posicao),
EXTRACT(MONTH FROM A.dt_posicao)||'-'||EXTRACT(YEAR FROM A.dt_posicao),
EXTRACT(MONTH FROM A.dt_posicao)||'-'||EXTRACT(YEAR FROM A.dt_posicao)||A.idrec,
A.dt_posicao






from tb_recurso a
left join tbsetor b on (a.idsetor = b.idsetor)
LEFT JOIN ccusto c on (b.idccusto = c.idccusto)
;



/* View: PRODUCAO_TRABALHADAS */
CREATE VIEW PRODUCAO_TRABALHADAS(
    ID,
    LANCAMENTO,
    DATA,
    DIA_SEM,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    QUANTIDADE,
    INICIO,
    FIM,
    CODIGO,
    PARADA,
    DESCRICAO,
    STATUS,
    TEMPO_TRAB,
    TEMPO_PARADO,
    TEMPO_LIQ,
    NOME_MAQUINA,
    TIPO_MAQUINA,
    NOME_TIPO_MAQUINA,
    SETOR,
    NOME_SETOR,
    SETOR_ROTEIRO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    SETUP_ROTEIRO,
    TEMPO_PREVISTO,
    PRODUCAO_PREV,
    PRODUCAO_PREVISTA,
    ANO,
    MES,
    CC,
    CC_ROTEIRO,
    T1,
    T2,
    T3)
AS
select
a.id AS ID,
a.lancamento AS LANCAMENTO,
a.data AS DATA,
f_dayofweek(a.data) AS DIA_SEM,
a.operador AS OPERADOR,
a.turno AS TURNO,
a.ordem AS ORDEM,

/*OPERACAO */
case when cast(a.operacao as integer) = 0
then 20
else
cast(a.operacao as integer)
end AS OPERACAO,

a.maquina AS MAQUINA,

/*PRODUCAO REAL QTDE */
cast(a.quantidade as numeric(12,6)) AS QUANTIDADE,

a.inicio AS INICIO,
a.fim AS FIM,
a.codigo AS CODIGO,
b.parada AS PARADA,
b.descricao AS DESCRICAO,
b.status AS STATUS,

/* Tempo Trabalhado */
case when
a.lancamento = 1 then
     case
        when a.turno = 1 then c.capt1
        when a.turno = 2 then c.capt2
        when a.turno = 3 then c.capt3
    else 0
    end
  /* a.tempo */
else
0
end AS TEMPO_TRAB,

/* Tempo Parado */
case when
a.lancamento = 1 then
0
else
a.tempo
end AS TEMPO_PARADO,

/*Tempo L�quido*/
case when
a.lancamento = 1  then
         case
        when a.turno = 1 then c.capt1
        when a.turno = 2 then c.capt2
        when a.turno = 3 then c.capt3
    else 0
    end
 /*  a.tempo */
else
a.tempo * -1
end AS TEMPO_LIQ,

c.nome_maquina AS NOME_MAQUINA,
C.setor  AS TIPO_MAQUINA,
C.nome_setor as NOME_TIPO_MAQUINA,
c.grupo AS SETOR,
c.nome_grupo AS NOME_SETOR,
d.nome AS SETOR_ROTEIRO,
d.ciclo AS CICLO_ROTEIRO,
d.ciclo_maq AS CICLO_MAQUINA,

d.setup AS SETUP_ROTEIRO,



/* Tempo Previsto */
case when
a.lancamento = 1 and d.ciclo_maq is not null and a.tempo > 0  then
cast(a.quantidade * d.ciclo_maq / 3600 as numeric(12,6))
else
0
end AS TEMPO_PREVISTO,

/*PRODUCAO PREVISTA QTDE */
case when
a.lancamento = 1 and d.ciclo > 0  then

    case
    when a.turno = 1 and c.capt1 > 0 then
    cast(((c.capt1)*3600)/d.ciclo as INTEGER)
    when a.turno = 2 and c.capt2 > 0 then
    cast(((c.capt2)*3600)/d.ciclo as INTEGER)
    when a.turno = 3 and c.capt3 > 0 then
    cast(((c.capt3)*3600)/d.ciclo as INTEGER)
    else
       cast(((a.tempo - 1)*3600)/d.ciclo as INTEGER)
    end



else
0
end AS PRODUCAO_PREV,

/*PRODUCAO PREVISTA QTDE */
case when
a.lancamento = 1 and d.ciclo > 0  then

    case
    when a.turno = 1 and c.capt1 > 0 then
    cast(((c.capt1)*3600)/d.ciclo as INTEGER)
    when a.turno = 2 and c.capt2 > 0 then
    cast(((c.capt2)*3600)/d.ciclo as INTEGER)
    when a.turno = 3 and c.capt3 > 0 then
    cast(((c.capt3)*3600)/d.ciclo as INTEGER)
    else
       cast(((a.tempo)*3600)/d.ciclo as INTEGER)
    end



else
0
end AS PRODUCAO_PREVISTA,


f_year(a.data) AS ANO,

f_month(a.data) AS MES ,

c.ncc AS CC,

d.cc_roteiro AS CC_ROTEIRO,

c.capt1, c.capt2, c.capt3

from
tb_apontamento a
inner join vw_setores c
on (a.maquina = c.maquina and f_month(a.data) = f_month(c.dt_posicao) and f_year(a.data) = f_year(c.dt_posicao))
left join
tb_motivos_parada b on (a.lancamento = b.parada)
left join tb_of_ciclo d on (a.ordem = d.ordem and
case when cast(a.operacao as integer) = 0
then 20
else
cast(a.operacao as integer) end = d.seq)
where a.data >= '01.01.2018' AND a.maquina not in ('4060','4061','4062')
;



/* View: PRODUCAO_TRABALHADAS_QTD */
CREATE VIEW PRODUCAO_TRABALHADAS_QTD(
    ID,
    LANCAMENTO,
    DATA,
    DIA_SEM,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    QUANTIDADE,
    CODIGO,
    PARADA,
    DESCRICAO,
    STATUS,
    NOME_MAQUINA,
    TIPO_MAQUINA,
    NOME_TIPO_MAQUINA,
    SETOR,
    NOME_SETOR,
    SETOR_ROTEIRO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    SETUP_ROTEIRO,
    ANO,
    MES,
    CC,
    CC_ROTEIRO,
    CAPT1,
    CAPT2,
    CAPT3)
AS
select
a.id AS ID,
a.lancamento AS LANCAMENTO,
a.data AS DATA,
f_dayofweek(a.data) AS DIA_SEM,
a.operador AS OPERADOR,
a.turno AS TURNO,
a.ordem AS ORDEM,

/*OPERACAO */
case when cast(a.operacao as integer) = 0
then 20
else
cast(a.operacao as integer)
end AS OPERACAO,

a.maquina AS MAQUINA,

/*PRODUCAO REAL QTDE */
cast(a.quantidade as numeric(12,6)) AS QUANTIDADE,


a.codigo AS CODIGO,
b.parada AS PARADA,
b.descricao AS DESCRICAO,
b.status AS STATUS,


c.nome_maquina AS NOME_MAQUINA,
C.setor  AS TIPO_MAQUINA,
C.nome_setor as NOME_TIPO_MAQUINA,
c.grupo AS SETOR,
c.nome_grupo AS NOME_SETOR,
d.nome AS SETOR_ROTEIRO,
d.ciclo AS CICLO_ROTEIRO,
d.ciclo_maq AS CICLO_MAQUINA,
d.setup AS SETUP_ROTEIRO,

f_year(a.data) AS ANO,

f_month(a.data) AS MES ,

c.ncc AS CC,

d.cc_roteiro AS CC_ROTEIRO,

c.capt1, c.capt2, c.capt3

from
tb_apontamento a
inner join vw_setores c
on (a.maquina = c.maquina and f_month(a.data) = f_month(c.dt_posicao) and f_year(a.data) = f_year(c.dt_posicao))
left join
tb_motivos_parada b on (a.lancamento = b.parada)
left join tb_of_ciclo d on (a.ordem = d.ordem and
case when cast(a.operacao as integer) = 0
then 20
else
cast(a.operacao as integer) end = d.seq)
where a.data >= '01.01.2018' AND a.maquina not in ('4060','4061','4062') and a.lancamento = 1 and a.quantidade > 0
;



/* View: VW_TB_ROTEIRO_SIMPLES */
CREATE VIEW VW_TB_ROTEIRO_SIMPLES(
    CODIGO,
    CICLO,
    PCHORA,
    SETUP,
    SETOR,
    SEQ,
    SEG_PECA)
AS
select codigo, ciclo, pchora, setup, setor,
case when ciclo = 'AT1' THEN '20'
ELSE '00'
END,
CASE when PCHORA > 0 THEN
cast((3600/PCHORA) as numeric(12,2))
ELSE 0
END

from tb_roteiro_simples
;



/* View: PRODUTIVIDADE */
CREATE VIEW PRODUTIVIDADE(
    ID,
    LANCAMENTO,
    DATA,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    QUANTIDADE,
    INICIO,
    FIM,
    CODIGO,
    TEMPO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    CICLO_REAL,
    CICLO_ORCADO,
    INDICE,
    INDICE_MINIMO,
    INDICE_MAXIMO,
    INDICE_DESTINO,
    MES,
    ANO,
    TEMPO_REAL,
    TEMPO_ORCADO)
AS
select a.id, a.lancamento, a.data, a.operador, a.turno, a.ordem, a.operacao,
a.maquina, a.quantidade, a.inicio, a.fim, a.codigo,
a.tempo  ,   c.nome_maquina, c.setor, c.nome_setor,
coalesce((a.tempo*3600)/a.quantidade,0), coalesce(b.seg_peca,0) , coalesce(b.seg_peca/((a.tempo*3600)/a.quantidade) *100,0) ,
65, 100, 85, f_month(a.data), f_year(a.data),
coalesce(a.tempo,0),
coalesce(cast((b.seg_peca*a.quantidade)/3600 as numeric(12,2)),0)

from tb_apontamento a
left join
vw_tb_roteiro_simples b on (a.codigo = b.codigo and a.operacao = b.seq)
left join setores c on (a.maquina = c.maquina)
where a.lancamento = 1
;



/* View: PRODUTOS_EGA */
CREATE VIEW PRODUTOS_EGA(
    CODIGO,
    OPERACAO,
    NOME_OPER,
    DESCRICAO,
    PECAS_CICLO,
    PECAS_HORA,
    CICLOS_PECA)
AS
select produto, tbarvoreproc.seq, tbarvoreproc.descroper,  tbitens.nomeitem,  undoper, pchora, 1
 from tbarvoreproc join tbitens on (tbarvoreproc.produto = tbitens.codigoitem)
;



/* View: PRODUTOS_INV */
CREATE VIEW PRODUTOS_INV(
    CODIGOITEM,
    NOMEITEM,
    UNDCOMPRAITEM,
    UNDUSOITEM,
    FATORCONVITEM,
    GRUPOITEM,
    PRECOCOMPRA,
    VALORCUSTOITEM,
    CUSTOMATITEM,
    CUSTOTRATITEM,
    CUSTOPROCITEM,
    ARVORE)
AS
select
codigoitem, nomeitem, undcompraitem, undusoitem, fatorconvitem, grupoitem, precocompra, valorcustoitem, customatitem, custotratitem, custoprocitem, arvore
from tbitens where grupoitem in('01','11','16','18','20')
;



/* View: PROJ_PED */
CREATE VIEW PROJ_PED(
    NUMPED,
    FORMAENV,
    IDITEM,
    IDNUMPED,
    CC1,
    CC2,
    CC3,
    CC4,
    CC5)
AS
select numped, formaenv,
iditem, idnumped, cc1, cc2, cc3, cc4, cc5 from tbpropc join tbpropitemc 
on (tbpropc.numped = tbpropitemc.idnumped)
;



/* View: PROXIMA_PREVENTIVA */
CREATE VIEW PROXIMA_PREVENTIVA(
    PROXIMA_DATA,
    OM,
    RECURSO,
    TIPO_MANUT,
    STATUS)
AS
select max(a.data_programada), max(a.n_cont),a.recurso, a.tipo_manut, a.status
from tb_om a
where tipo_manut = 2 and a.data_programada is not null and a.recurso is not null and status IN (2,3)
group by a.recurso, a.tipo_manut, a.status
;



/* View: QET */
CREATE VIEW QET(
    ET,
    TIPO,
    CODIGO,
    DESCRCODIGO,
    RESTRICOES,
    INFCOMPL,
    ELABPOR,
    FUNCAOELAB,
    DATAELAB,
    APROVPOR,
    FUNCAOAPROV,
    DATAAPROV,
    ULTREV,
    DATAREV,
    REQUERCERT,
    ESPECIFCONF,
    NORMAAPLIC,
    OBSERVACOES,
    IDITEM,
    IDET,
    ITEMSEQ,
    CARACTERISTICA,
    REFERENCIA,
    DIMENSAO,
    TOLMAX,
    TOLMIN,
    NORMA,
    UND,
    CQ,
    OBSITEM,
    ITCERT,
    CAMINHO,
    DESCRICAO_TIPO,
    FERRAMENTA,
    ESPECIAL,
    DESCRICAO_FERRAMENTA)
AS
select
ET, TIPO, CODIGO, DESCRCODIGO, RESTRICOES, INFCOMPL, ELABPOR, FUNCAOELAB, DATAELAB, APROVPOR, FUNCAOAPROV, DATAAPROV, ULTREV, DATAREV, REQUERCERT, ESPECIFCONF, NORMAAPLIC, OBSERVACOES,
IDITEM, IDET, ITEMSEQ, CARACTERISTICA, REFERENCIA, DIMENSAO, TOLMAX, TOLMIN, NORMA, UND, CQ, OBSITEM, ITCERT, caminho,
tbtipoet.descrtipo, FERRAMENTA, ESPECIAL, tbitens.nomeitem
from tbet left JOIN (TBETITEM left join tbitens on (tbetitem.ferramenta = tbitens.codigoitem))
left join tbtipoet on (tbet.tipo = tbtipoet.tipoet)
ON(ET=IDET)
;



/* View: QOS */
CREATE VIEW QOS(
    OSNUM,
    OSIDITEM,
    OSIDNUMPED,
    COMP,
    LARG,
    ALT,
    ESP,
    ITEMNOVO,
    QTDECORES,
    COR1,
    COR2,
    COR3,
    COR4,
    COR5,
    COR6,
    CANTOS,
    QTDEFURO1,
    DIAMFURO1,
    QTDEFURO2,
    DIAMFURO2,
    QTDEFURO3,
    DIAMFURO3,
    QTDEFURO4,
    DIAMFURO4,
    QTDEFURO5,
    DIAMFURO5,
    QTDEFURO6,
    DIAMFURO6,
    ADESIVO,
    MASCARA,
    NUMERACAO,
    NUMDE,
    NUMATE,
    TIPONUM,
    ARTEFINAL,
    ENVIARPOR,
    MONTAGEM,
    FACA,
    PRAZOPCP,
    MATERIAL,
    INFO,
    CODIGOITEM,
    DIAMETRO,
    CORVERSO1,
    CORVERSO2,
    CORVERSO3,
    QTDPROD,
    ACABAMENTO,
    CODMAT,
    VOLUMES,
    PESOUNIT,
    PESOTOT,
    PERDA,
    PAPEL,
    LARGURA_PAPEL,
    COLUNAS,
    ETIQ_COLUNA,
    INTERV_VERTICAL,
    INTERV_HORIZONTAL,
    DIAM_FACA,
    DIAM_CILINDRO,
    ENGRENAGEM)
AS
select osnum, osiditem, osidnumped, comp, larg, alt, esp,
case tbosgraf.itemnovo
when 1 then 'N�O'
when 0 then 'SIM'
else '-'
end,
qtdecores, cor1, cor2, cor3, cor4, cor5, cor6,
case tbosgraf.cantos
when 1 then 'RETOS'
when 2 then 'ARREDONDADOS'
when 3 then 'QUEBRADOS'
else '-'
end
, qtdefuro1, diamfuro1, qtdefuro2, diamfuro2, qtdefuro3, diamfuro3, qtdefuro4, diamfuro4, qtdefuro5, diamfuro5, qtdefuro6, diamfuro6, adesivo, mascara, numeracao, numde, numate, tiponum, artefinal, enviarpor, montagem, faca, prazopcp, material, info, codigoitem,
diametro, corverso1, corverso2, corverso3, qtdprod, acabamento, codmat, volumes, pesounit, pesotot, perda, papel, largura_papel, colunas, etiq_coluna, interv_vertical, interv_horizontal, diam_faca, diam_cilindro, engrenagem from tbosgraf
;



/* View: QT_PEDIDOS */
CREATE VIEW QT_PEDIDOS(
    NUMPED,
    CODCLI,
    CONTATO,
    RAZAO,
    CODPROD,
    NOMEPROD,
    UND,
    DESCORCAM,
    STP,
    PL)
AS
select
numped,codcli,contato,razao,codprod,nomeprod,und,descorcam, tbpropc.status, tbpropc.pednovo 
from tbpropc left join tbpropitemc  on (tbpropc.numped = tbpropitemc.idnumped)
group by numped,codcli,contato,razao,codprod,nomeprod,und,descorcam, tbpropc.status, tbpropc.pednovo
having (tbpropc.status=4 and tbpropc.pednovo =0)
;



/* View: RCVIEW */
CREATE VIEW RCVIEW(
    TBRCQRC,
    TBRCQTIPO,
    TBRCQSETOR)
AS
select TBRCQRC, TBRCQTIPO, TBRCQSETOR from tbrcq
;



/* View: RECEBIDOS */
CREATE VIEW RECEBIDOS(
    NUMPED,
    DOCTO,
    CODIGO_PROD,
    DESCR,
    QTDE_PED,
    PRAZO_ENT,
    QTDE_ENT,
    DATA_ENT,
    CODFOR,
    FORNECEDOR,
    TIPO_R)
AS
select  tbitensnfc.numped,  tbnfc.PEDIDOCLI, CODIGOITEM, DESCRICAO, 0, NULL,QTDEITEM,TBNFC.sistema, TBNFC.codcli , TBNFC.fantasia, 1
from tbNFc join tbitensnfc  on (IDNUMNF = NUMNF)
where sistema >= '01.09.2008' and qtdeitem > 0
order by tbnfc.codcli, codigoitem,tbnfc.sistema
;



/* View: RECEBIMENTO */
CREATE VIEW RECEBIMENTO(
    DATA,
    LOTE,
    CODIGO,
    CODCF,
    DESCCF,
    DOC,
    QTDE,
    REG,
    TFORN,
    OPERACAO,
    UNID,
    OS)
AS
select entrada, lote, TBLOTE.codigoitem, codfor, tbforfan, nota_fiscal, qtdetotal,
case
when posicao = 'PENDENTE' THEN null
ELSE
'S'
END
,
TBLOTE.tipo ,
'',
TBITENS.undusoitem , TBLOTE.os 
 from tblote LEFT JOIN TBFOR ON (TBLOTE.codfor = TBFOR.tbforcod) LEFT JOIN tbitens ON (TBLOTE.codigoitem = TBITENS.codigoitem)
where TBLOTE.posicao = 'PENDENTE' AND CODFOR <> 0 AND NOTA_FISCAL <> '' and tbitens.inspecionaitem = 'S'
;



/* View: RECURSO1 */
CREATE VIEW RECURSO1(
    IDPROC,
    RECURSO,
    NOME)
AS
select a.idarvproc, a.idrec1, b.nomerec from tbarvoreproc a
left join tbrecurso b on (a.idrec1 = b.idrec)
;



/* View: RECURSO2 */
CREATE VIEW RECURSO2(
    IDPROC,
    RECURSO,
    NOME)
AS
select a.idarvproc, a.idrec2, b.nomerec from tbarvoreproc a
left join tbrecurso b on (a.idrec2 = b.idrec)
;



/* View: RECURSO3 */
CREATE VIEW RECURSO3(
    IDPROC,
    RECURSO,
    NOME)
AS
select a.idarvproc, a.idrec3, b.nomerec from tbarvoreproc a
left join tbrecurso b on (a.idrec3 = b.idrec)
;



/* View: RECURSOS_COMUNS */
CREATE VIEW RECURSOS_COMUNS(
    IDPROC,
    RECURSO,
    NOME)
AS
select idproc, recurso, nome
from recurso1 union all
select idproc, recurso, nome
from recurso2 union all
select idproc, recurso, nome
from recurso3
;



/* View: RECUSA_MES */
CREATE VIEW RECUSA_MES(
    MES_ANO,
    TOTAL,
    MES,
    ANO,
    MESNUM)
AS
select mes_ano, SUM(valortotalnf), mes, ano, mesnum from nf_dev_prod_fat
GROUP BY mes_ano, mes, ano, mesnum order by ANO, MESNUM
;



/* View: REFUGOS */
CREATE VIEW REFUGOS(
    MES,
    DATA,
    CODIGO,
    CLIENTE,
    QTDE,
    MAQUINA,
    SETOR,
    PRECO,
    VALOR_TOTAL)
AS
select f_padleft(f_month(a.data),'0',2)||'/'||f_year(a.data), a.data,  a.codigo, d.tbforfan,
a.qtde, a.maquina, c.nome_setor, cast((b.precovenda/b.fatorconven) as numeric(12,4)), cast((b.precovenda/b.fatorconven) * a.qtde as numeric(12,2))
from tb_eventos_os a
left join (tbitens b left join tbfor d on (b.codclitem = d.tbforcod)) on (a.codigo = b.codigoitem)
left join setores c on (a.maquina = c.maquina)
where a.evento = 'REFUGO'
;



/* View: REPROVADOS2 */
CREATE VIEW REPROVADOS2(
    MES,
    DATA,
    CODIGO,
    CLIENTE,
    QTDE,
    MAQUINA,
    SETOR,
    PRECO,
    VALOR_TOTAL)
AS
select f_padleft(f_month(a.data_inspecao),'0',2)||'/'||f_year(a.data_inspecao),  a.data_inspecao, a.codigo, a.cliente, a.scrap, a.maquina, 'N�O CONFORME', a.preco,
a.scrap * a.preco
from apontamentos_valor a
where a.scrap > 0
;



/* View: REFUGO_TOTAL */
CREATE VIEW REFUGO_TOTAL(
    MES,
    DATA,
    CODIGO,
    CLIENTE,
    QTDE,
    MAQUINA,
    SETOR,
    PRECO,
    VALOR_TOTAL)
AS
select mes, data, codigo, cliente, qtde, maquina, setor, preco, valor_total
from refugos UNION ALL
select mes, data, codigo, cliente, qtde, maquina, setor, preco, valor_total
from REPROVADOS2
;



/* View: RELEASE_PEDIDOS */
CREATE VIEW RELEASE_PEDIDOS(
    DATA,
    DIA,
    CLIENTE,
    PRODUTO,
    DESCRICAO,
    QTDE,
    UNITARIO,
    TOTAL,
    STATUS,
    DD,
    MM,
    AA,
    SEM,
    ATRASO,
    NC,
    CRITICO,
    CODCLI)
AS
select CAST(DATA AS DATE), DIA, CLIENTE, PRODUTO, TBITENS.nomeitem,  QTDE, UNITARIO, TOTAL,

case when STATUS = '0' then 'FRM'
WHEN STATUS = '1' THEN 'PRV'
WHEN STATUS = '2' THEN 'FRM'
WHEN STATUS = '3' THEN 'FAT'
WHEN STATUS = '4' THEN 'CNG'
END, DD, MM, AA, SEM,
case
WHEN DATA < current_date and status not in ('03','04') THEN '01-SIM'
else '02-N�O' END, '', CRITICO , cast(codigo_cliente as varchar(120))
from TB_ESTATISTICA LEFT JOIN tbitens ON (tb_estatistica.produto = TBITENS.codigoitem)
;



/* View: REMESSA_TERCEIRO */
CREATE VIEW REMESSA_TERCEIRO(
    CODIGOMAT,
    OS,
    QTD_MOV,
    PROGRAMA,
    N_ET)
AS
select TB_TERCEIRO.codigomat, TB_TERCEIRO.os, sum(qtd_mov), TB_OS.qtde_produzir,
notasfiscais.n_et
from tb_terceiro  LEFT JOIN TB_OS ON (TB_TERCEIRO.OS = TB_OS.numero_os)
left join notasfiscais on (tb_terceiro.nota_saida = notasfiscais.nf_numero and tb_terceiro.codfor = notasfiscais.codcli and tb_terceiro.codigomat = notasfiscais.codigoitem)
WHERE TB_TERCEIRO.STATUS = 'SAIDA NF'
group by 
TB_TERCEIRO.CODIGOMAT,
TB_TERCEIRO.OS,
TB_OS.qtde_produzir, notasfiscais.n_et
;



/* View: REPROVADOS */
CREATE VIEW REPROVADOS(
    MES,
    DATA,
    CODIGO,
    CLIENTE,
    QTDE,
    MAQUINA,
    SETOR,
    PRECO,
    VALOR_TOTAL)
AS
select f_padleft(f_month(a.data_inspecao),'0',2)||'/'||f_year(a.data_inspecao),  a.data_inspecao, a.codigo, a.cliente, a.scrap, a.maquina, a.setor, a.preco,
a.valor_sucata
from apontamentos_valor a
where a.scrap > 0
;



/* View: REQEPI */
CREATE VIEW REQEPI(
    IDCOT,
    DATACOT,
    REFCOT,
    CODIGOITEM,
    DESCITEM,
    UNDCOMPRA,
    QTDE,
    PRAZOSOL,
    OPNUM,
    OBSCOT,
    REQUISITANTE,
    SETOR,
    DESTINO,
    NCC,
    TIPOITEM,
    USERNOME,
    NOMESETOR)
AS
select
a.idcot, a.datacot, a.refcot, a.codigoitem, a.descitem, a.undcompra, a.qtde, a.prazosol, a.opnum, a.obscot, a.requisitante, c.usersetor, A.destino, C.n_cc,
b.tipoitem,
c.usernome, c.usersetor
from tbcot a left join tbitens b on (a.codigoitem = b.codigoitem) left join tb_user c on (a.requisitante = c.registro)
WHERE b.tipoitem = 'EPI'
;



/* View: RESUMO_KPI_MANUTENCAO */
CREATE VIEW RESUMO_KPI_MANUTENCAO(
    SETOR,
    NOME_SETOR,
    RECURSO,
    JAN_OM,
    JAN_HS,
    FEV_OM,
    FEV_HS,
    MAR_OM,
    MAR_HS,
    ABR_OM,
    ABR_HS,
    MAI_OM,
    MAI_HS,
    JUN_OM,
    JUN_HS,
    JUL_OM,
    JUL_HS,
    AGO_OM,
    AGO_HS,
    SET_OM,
    SET_HS,
    OUT_OM,
    OUT_HS,
    NOV_OM,
    NOV_HS,
    DEZ_OM,
    DEZ_HS,
    DISP_MES,
    ANO_SOLIC)
AS
select a.setor, a.nome_setor, a.recurso,
sum(a.jan_om) as jan_om,
sum(a.jan_hs) as jan_hs,
sum(a.fev_om) as fev_om,
sum(a.fev_hs) as fev_hs,
sum(a.mar_om) as mar_om,
sum(a.mar_hs) as mar_hs,
sum(a.abr_om) as abr_om,
sum(a.abr_hs) as abr_hs,
sum(a.mai_om) as mai_om,
sum(a.mai_hs) as mai_hs,
sum(a.jun_om) as jun_om,
sum(a.jun_hs) as jun_hs,
sum(a.jul_om) as jul_om,
sum(a.jul_hs) as jul_hs,
sum(a.ago_om) as ago_om,
sum(a.ago_hs) as ago_hs,
sum(a.set_om) as set_om,
sum(a.set_hs) as set_hs,
sum(a.out_om) as out_om,
sum(a.out_hs) as out_hs,
sum(a.nov_om) as nov_om,
sum(a.nov_hs) as nov_hs,
sum(a.dez_om) as dez_om,
sum(a.dez_hs) as dez_hs,
a.disp_mes, a.ano_solic
from kpi_manutencao a
group by a.setor, a.nome_setor, a.recurso, a.disp_mes, a.ano_solic
;



/* View: RESUMO_MANUTENCAO_SETOR */
CREATE VIEW RESUMO_MANUTENCAO_SETOR(
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    RECURSO,
    QTD_OM,
    QTD_HORAS,
    DISP_MES,
    TIPO_MANUT,
    NATUREZA_MANUT,
    ANO_SOLIC,
    MES_OM)
AS
select b.mes_solic, a.setor, a.nome_setor, a.maquina, count(b.n_cont) as qtd_om, sum(b.tempo_gasto) as parada,
a.captotmes, b.natureza_manut, b.tipo_manut, b.ano_solic, b.mes_om
from recursos a left join horas_manutencao b on (a.maquina=b.recurso)
where a.tipo = 'MOD'
group by b.mes_solic, a.setor, a.nome_setor, a.maquina, b.natureza_manut, b.tipo_manut, a.captotmes, b.ano_solic, b.mes_om
order by a.setor, a.maquina, b.ano_solic, b.mes_om
;



/* View: RESUMO_MOVIMENTO */
CREATE VIEW RESUMO_MOVIMENTO(
    COD_PARAMETRO,
    NOME_PARAMETRO,
    GRUPO,
    MES_LANC,
    QTD_MOV,
    VALOR_MOV,
    TIPO_ITEM)
AS
select cod_parametro,
nome_parametro, grupo, mes_lanc, sum(qtd_mov), sum(valor_mov), tipo_item from movimento
group by cod_parametro,
nome_parametro, grupo, mes_lanc, tipo_item
;



/* View: RESUMO_NOTAS */
CREATE VIEW RESUMO_NOTAS(
    NUMNF,
    EMISSAO,
    CANC,
    CFOP,
    VALORITENS,
    VALORTOTALNF,
    NATUREZA)
AS
select numnf, emissao, canc, cfop, valoritens, valortotalnf,
CASE tbnf.stacom
WHEN 0 THEN 'VENDA/PRODUTOS'
WHEN 1 THEN 'VENDA/OUTROS'
WHEN 2 THEN 'SERV.TERCEIROS'
WHEN 3 THEN 'VENDA/FERRAM.'
when 4 then 'MAO DE OBRA'
WHEN 5 THEN 'OUTROS'
WHEN 6 THEN 'NF COMPL.'
END
from tbnf where emissao between '01.04.2009' and '30.04.2009' and canc = 'N'
;



/* View: RESUMO_PEDIDO_CAC */
CREATE VIEW RESUMO_PEDIDO_CAC(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    ST,
    APROVACAO,
    CODPROD,
    NOMEPROD,
    DESENHOITEM,
    TOTPED,
    TOTENT,
    VLUNIT,
    TOTSALDO,
    PEDIDOCLI,
    UND,
    FCVENDA,
    COMPLEMENTO,
    STPREV)
AS
select
numped, codcli, fantasia, cpag, st, aprovacao, codprod, nomeprod,desenhoitem, sum(qtdeped), sum(qtdeent), vlunit, sum(saldo), pedidocli, und, fcvenda, complemento, stprev
from pedido
group by
numped, codcli, fantasia, cpag, st, aprovacao, codprod, nomeprod,desenhoitem, vlunit, pedidocli, und, fcvenda, complemento, stprev
;



/* View: RESUMO_PEDIDO_VENDA */
CREATE VIEW RESUMO_PEDIDO_VENDA(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    ST,
    APROVACAO,
    CODPROD,
    NOMEPROD,
    DESENHOITEM,
    TOTPED,
    TOTENT,
    VLUNIT,
    TOTSALDO,
    PEDIDOCLI,
    UND,
    FCVENDA,
    COMPLEMENTO,
    STPREV)
AS
select
numped, codcli, fantasia, cpag, st, aprovacao, codprod, nomeprod,desenhoitem, sum(qtdeped), sum(qtdeent), vlunit, sum(saldo), pedidocli, und, fcvenda, complemento, stprev
from pedido
group by
numped, codcli, fantasia, cpag, st, aprovacao, codprod, nomeprod,desenhoitem, vlunit, pedidocli, und, fcvenda, complemento, stprev
having (pedido.st = 4 and stprev <> 1)
;



/* View: RESUMO_PRODUCAO */
CREATE VIEW RESUMO_PRODUCAO(
    DATA,
    SETOR,
    NOME_MAQUINA,
    MAQUINA,
    PRODUTO,
    OPERACAO,
    ORDEM,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    REALIZADO1,
    HS_PARADAS1,
    HS_TRAB1,
    TEMPO_LIQ1,
    TEMPO_PROD1,
    PREVISTO1,
    EFIC1,
    REALIZADO2,
    HS_PARADAS2,
    HS_TRAB2,
    TEMPO_LIQ2,
    TEMPO_PROD2,
    PREVISTO2,
    EFIC2,
    REALIZADO3,
    HS_PARADAS3,
    HS_TRAB3,
    TEMPO_LIQ3,
    TEMPO_PROD3,
    PREVISTO3,
    EFIC3,
    REALIZADO_TOTAL,
    HS_PARADAS_TOTAL,
    HS_TRAB_TOTAL,
    TEMPO_LIQ_TOTAL,
    TEMPO_PROD_TOTAL,
    PREVISTO_TOTAL,
    EFIC_TOTAL,
    SETOR_ROTEIRO,
    CC,
    CC_ROTEIRO,
    ANO,
    MES)
AS
with CTE_RES
AS
(
select
a.data as data,
a.nome_setor as setor,
a.nome_maquina as nome_maquina,
a.maquina as maquina,
a.codigo AS PRODUTO,
a.operacao as OPERACAO,
a.ordem as ordem,
a.ciclo_roteiro as ciclo_roteiro,
a.ciclo_maquina as ciclo_maquina,
sum(case when a.turno = 1 then
a.quantidade  else 0 end) AS REALIZADO1,
sum(case when a.turno = 1 then
a.tempo_parado else 0 end) as HS_PARADAS1 ,
sum(case when a.turno = 1 then
a.tempo_trab else 0 end) as HS_TRAB1 ,
sum(case when a.turno = 1 then
a.tempo_liq else 0 end) as TEMPO_LIQ1 ,
sum(case when a.turno = 1 then
a.quantidade * a.ciclo_maquina else 0 end)  AS tempo_prod1 ,
sum(case when a.turno = 2 then
a.quantidade else 0 end)  AS REALIZADO2 ,
sum(case when a.turno = 2 then
a.tempo_parado else 0 end) as HS_PARADAS2 ,
sum(case when a.turno = 2 then
a.tempo_trab else 0 end) as HS_TRAB2 ,
sum(case when a.turno = 2 then
a.tempo_liq else 0 end)  as TEMPO_LIQ2 ,
sum(case when a.turno = 2 then
a.quantidade * a.ciclo_maquina else 0 end)  AS tempo_prod2 ,
sum(case when a.turno = 3 then
a.quantidade else 0 end)  AS REALIZADO3 ,
sum(case when a.turno = 3 then
a.tempo_parado else 0 end) as HS_PARADAS3 ,
sum(case when a.turno = 3 then
a.tempo_trab else 0 end) as HS_TRAB3 ,
sum(case when a.turno = 3 then
a.tempo_liq else 0 end) as TEMPO_LIQ3,
sum(case when a.turno = 3 then
a.quantidade * a.ciclo_maquina else 0 end)  AS tempo_prod3 ,
A.setor_roteiro as setor_roteiro ,
a.cc ,
A.cc_roteiro,
A.ANO,
A.MES
from producao_trabalhadas a
GROUP BY
a.data, 
a.nome_setor,
a.nome_maquina,
a.maquina,
a.codigo,
a.operacao,
a.ordem, 
a.ciclo_roteiro,
a.ciclo_maquina, 
A.setor_roteiro,
a.cc, A.cc_roteiro, A.ANO, A.MES
),
CTE_TOTAL
AS
(
select
a.data,
a.setor,
a.nome_maquina,
a.maquina,
a.PRODUTO,
a.OPERACAO,
a.ordem,
a.ciclo_roteiro,
a.ciclo_maquina,
a.REALIZADO1,
a.HS_PARADAS1 ,
a.HS_TRAB1 ,
a.TEMPO_LIQ1 ,
a.tempo_prod1 ,
cast(case when a.ciclo_roteiro > 0 AND A.TEMPO_LIQ1 > 0 then
(3600/a.ciclo_roteiro*a.tempo_liq1) else 0 end as integer) AS PREVISTO1 ,
CASE WHEN A.REALIZADO1 <> 0 AND a.ciclo_roteiro <> 0 AND A.TEMPO_LIQ1 > 0 then
CAST(a.REALIZADO1/(3600/a.ciclo_roteiro*a.tempo_liq1) AS numeric(12,6))
ELSE
0
END AS EFIC1,
a.REALIZADO2 ,
a.HS_PARADAS2 ,
a.HS_TRAB2 ,
a.TEMPO_LIQ2 ,
a.tempo_prod2 ,
cast(case when a.ciclo_roteiro > 0 AND A.TEMPO_LIQ2 > 0 then
(3600/a.ciclo_roteiro*a.tempo_liq2) else 0 end as integer) AS PREVISTO2 ,
CASE WHEN A.REALIZADO2 <> 0 AND a.ciclo_roteiro <> 0 AND A.TEMPO_LIQ2 > 0 then
CAST(a.REALIZADO2/(3600/a.ciclo_roteiro*a.tempo_liq2) AS numeric(12,6))
ELSE
0
END AS EFIC2,
a.REALIZADO3 ,
a.HS_PARADAS3 ,
a.HS_TRAB3 ,
a.TEMPO_LIQ3,
a.tempo_prod3 ,
cast(case when a.ciclo_roteiro > 0 AND A.TEMPO_LIQ3 > 0 then
(3600/a.ciclo_roteiro*a.tempo_liq3) else 0 end as integer) AS PREVISTO3 ,
CASE WHEN A.REALIZADO3 <> 0 AND a.ciclo_roteiro <> 0 AND A.TEMPO_LIQ3 > 0 then
CAST(a.REALIZADO3/(3600/a.ciclo_roteiro*a.tempo_liq3) AS numeric(12,6))
ELSE
0
END AS EFIC3 ,
A.setor_roteiro,
a.cc,
A.cc_roteiro,
A.ANO,
A.MES
FROM CTE_RES A
)
select
a.data,
a.setor,
a.nome_maquina,
a.maquina,
a.PRODUTO,
a.OPERACAO,
a.ordem,
a.ciclo_roteiro,
a.ciclo_maquina,
a.REALIZADO1,
a.HS_PARADAS1 ,
a.HS_TRAB1 ,
a.TEMPO_LIQ1 ,
a.tempo_prod1 ,
A.PREVISTO1 ,
A.EFIC1,
a.REALIZADO2 ,
a.HS_PARADAS2 ,
a.HS_TRAB2 ,
a.TEMPO_LIQ2 ,
a.tempo_prod2 ,
A.PREVISTO2 ,
A.EFIC2,
a.REALIZADO3 ,
a.HS_PARADAS3 ,
a.HS_TRAB3 ,
a.TEMPO_LIQ3,
a.tempo_prod3 ,
A.PREVISTO3 ,
A.EFIC3 ,
A.REALIZADO1+A.REALIZADO2+A.REALIZADO3 AS REALIZADO_TOTAL,
a.HS_PARADAS1+a.HS_PARADAS2+a.HS_PARADAS3 AS HS_PARADAS_TOTAL,
a.HS_TRAB1+a.HS_TRAB2+a.HS_TRAB3 AS HS_TRAB_TOTAL,
a.TEMPO_LIQ1+A.TEMPO_LIQ2+A.TEMPO_LIQ3 AS TEMPO_LIQ_TOTAL,
a.tempo_prod1+A.TEMPO_PROD2+A.TEMPO_PROD3 AS TEMPO_PROD_TOTAL,
A.PREVISTO1+A.PREVISTO2+A.PREVISTO3 AS PREVISTO_TOTAL,
CASE WHEN A.REALIZADO1+A.REALIZADO2+A.REALIZADO3 <> 0 AND A.PREVISTO1+A.PREVISTO2+A.PREVISTO3 <> 0 then
CAST((a.REALIZADO1+A.REALIZADO2+A.REALIZADO3)/(A.PREVISTO1+A.PREVISTO2+A.PREVISTO3) AS numeric(12,6))
ELSE
0
END AS EFIC_TOTAL,
A.setor_roteiro,
a.cc,
A.cc_roteiro,
A.ANO,
A.MES
FROM CTE_TOTAL A
;



/* View: RETORNOS */
CREATE VIEW RETORNOS(
    IDLANC,
    CODIGOMAT,
    UND,
    QTDESERV,
    QTD_MOV,
    QTD_NOTA,
    UND_NOTA,
    PESO_LIQ,
    PECAS,
    UND_USO)
AS
select idlanc, codigomat, und, qtdeserv, qtd_mov, qtd_nota, und_nota, tbitens.pesoliqitem, cast(qtdeserv/tbitens.pesoliqitem as numeric(15,0)), tbitens.undusoitem 
from movimento_retorno left join tbitens on (codigomat = codigoitem) where und_nota = 'KG' and tbitens.undusoitem = 'PC' order by idlanc
;



/* View: RNC */
CREATE VIEW RNC(
    RNC_N,
    ANO,
    EMITENTE,
    DATA,
    ORIGEM,
    NOME,
    OP,
    SETOR,
    OPERACAO,
    TIPO,
    NF,
    DATANF,
    QTDE,
    QTDE_NC,
    PRODUTO,
    NOME_PRODUTO,
    DESENHO,
    DETECTADO,
    ESPECIFICADO,
    OBTIDO,
    DISPOSICAO,
    DISP_OUTROS,
    DISP_RESP,
    DISP_PRAZO,
    DISP_VISTO,
    DISP_MAIL,
    CONTENCAO,
    CONT_RESP,
    CONT_PRAZO,
    CONT_VISTO,
    CONT_MAIL,
    CAUSA_NC,
    ACAO_TIPO,
    ACAO_DESC,
    ACAO_PRAZO,
    ACAO_REAL,
    ACAO_RESP,
    ACAO_DATA,
    ACAO_VISTO,
    ACAO_MAIL,
    EFICACIA,
    EFIC_RESP,
    EFIC_DATA,
    EFIC_VISTO,
    EFIC_MAIL,
    SAC,
    EFICACIA_OK,
    NOVA_RNC,
    COMPLEMENTO,
    LOTES,
    CODFOR,
    NUMOPER,
    REINCIDE,
    DISPACEITA,
    CONTACEITA,
    ACAOACEITA,
    EFICACEITA,
    RESPONDIDA,
    CLIENTE,
    IDRNC,
    DEFEITO,
    REC_CLIENTE)
AS
select rncnum, rncano, rncemitente, rncdata, rncorigem, rncnome, rncoprod, rncsetor, rncoper, rnctipo, rncnf, rncdatanf, rncqtde, rncqtdenc, rnccodprod, rncnomeprod, rncdesenho, rncdetec, rncespecif, rncdescnc, rncdispos, rncdispoutros, rncdispresp, rncdispprazo, rncdispvisto, rncdispmail, rnccontencao, rnccontresp, rnccontprazo, rnccontvisto, rnccontmail, rnccausanc, rncacaotipo, rncacaodesc, rncacaoprazo, rncacaoreal, rncacaoresp, rncacaodata, rncacaovisto, rncacaomail, rnceficacia, rnceficresp, rnceficdata, rnceficvisto, rnceficmail, rncsacnum, rnceficaciaok, rncnovarnc, rnccomplem,rnclotes,rnccodfor, tbrnc.rncnumoper,rncreincide, rncdispaceita, rnccontaceita, rncacaoaceita, rnceficaceita, rncrespondida, rncnome,idrnc, defeito, rec_cliente from tbrnc
;



/* View: RNC_ACAO */
CREATE VIEW RNC_ACAO(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE,
    MAIL)
AS
select
rncdata,
rncemitente,
rncnum || '/' || rncano,
'RESPONDER A��O',
RNCACAORESP,
RNCACAODATA, TBRNC.rnccodprod , TBRNC.rncnomeprod, TBRNC.rncnome, tbrnc.rncacaomail
from TBRNC WHERE RNCANO >= '14' AND TBRNC.rncacaoaceita = 0
;



/* View: RNC_COMPLEMENTAR */
CREATE VIEW RNC_COMPLEMENTAR(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE,
    MAIL)
AS
select
a.rncdata,
a.rncemitente,
a.rncnum || '/' || a.rncano,
b.pendencia || ' - ' || b.acao,
b.responsavel,
b.prazo, a.rnccodprod , a.rncnomeprod, a.rncnome, b.email
from TBRNC a JOIN tb_acao_rnc b on (a.rncnum = b.numrnc) WHERE a.RNCANO >= '14' AND b.aceita = 0
;



/* View: RNC_CONTENCAO */
CREATE VIEW RNC_CONTENCAO(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE,
    MAIL)
AS
select
rncdata,
rncemitente,
rncnum || '/' || rncano,
'A��O DE CONTEN��O',
RNCCONTRESP,
RNCCONTPRAZO, TBRNC.rnccodprod , TBRNC.rncnomeprod, TBRNC.rncnome, tbrnc.rnccontmail
from TBRNC WHERE RNCANO >= '14' AND TBRNC.rnccontaceita = 0
;



/* View: RNC_EFICACIA */
CREATE VIEW RNC_EFICACIA(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE,
    MAIL)
AS
select
rncdata,
rncemitente,
rncnum || '/' || rncano,
'VERIFICAR EFIC�CIA',
RNCEFICRESP,
RNCEFICDATA, TBRNC.rnccodprod , TBRNC.rncnomeprod, TBRNC.rncnome, tbrnc.rnceficmail
from TBRNC WHERE RNCANO >= '14' AND TBRNC.rnceficaceita = 0
;



/* View: RNC_FECHAMENTO */
CREATE VIEW RNC_FECHAMENTO(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE)
AS
select
rncdata,
rncemitente,
rncnum || '/' || rncano,
'FECHAMENTO RNC',
'SETOR QUALIDADE',
RNCACAODATA, TBRNC.rnccodprod , TBRNC.rncnomeprod, TBRNC.rncnome
from TBRNC WHERE RNCANO >= '10' AND TBRNC.rncacaoaceita = 0
;



/* View: RNC_FECHAMENTO_ACAO */
CREATE VIEW RNC_FECHAMENTO_ACAO(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE)
AS
select
rncdata,
rncemitente,
rncnum || '/' || rncano,
'VALIDAR A��O',
'QUALIDADE',
RNCACAODATA, TBRNC.rnccodprod , TBRNC.rncnomeprod, TBRNC.rncnome
from TBRNC WHERE TBRNC.rncacaoaceita = 0 and f_stringlength4(tbrnc.rncacaodesc)> 20
;



/* View: RNC_FECHAMENTO_CONTENCAO */
CREATE VIEW RNC_FECHAMENTO_CONTENCAO(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE)
AS
select
rncdata,
rncemitente,
rncnum || '/' || rncano,
'VALIDAR CONTENCAO',
'QUALIDADE',
RNCACAODATA, TBRNC.rnccodprod , TBRNC.rncnomeprod, TBRNC.rncnome
from TBRNC WHERE TBRNC.rnccontaceita = 0 and f_stringlength4(tbrnc.rnccontencao)> 20
;



/* View: RNC_FECHAMENTO_EFICACIA */
CREATE VIEW RNC_FECHAMENTO_EFICACIA(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE)
AS
select
rncdata,
rncemitente,
rncnum || '/' || rncano,
'VALIDAR EFICACIA',
'QUALIDADE',
RNCACAODATA, TBRNC.rnccodprod , TBRNC.rncnomeprod, TBRNC.rncnome
from TBRNC WHERE TBRNC.rnceficaceita = 0 and f_stringlength4(tbrnc.rnceficacia)> 20
;



/* View: RNC_GERAL */
CREATE VIEW RNC_GERAL(
    DATA,
    EMITENTE,
    RNC_N,
    PENDENCIA,
    RESPONSAVEL,
    PRAZO,
    ITEM,
    NOME,
    ENTIDADE,
    MAIL)
AS
SELECT rnc_contencao.data  , rnc_contencao.emitente, rnc_contencao.rnc_n, rnc_contencao.pendencia, rnc_contencao.responsavel, rnc_contencao.prazo, rnc_contencao.item, rnc_contencao.nome, rnc_contencao.entidade, rnc_contencao.mail
FROM RNC_CONTENCAO UNION ALL SELECT rnc_ACAO.data  , rnc_ACAO.emitente, rnc_ACAO.rnc_n, rnc_ACAO.pendencia, rnc_ACAO.responsavel, rnc_ACAO.prazo, RNC_ACAO.item, rnc_acao.NOME, rnc_acao.entidade, rnc_acao.mail
FROM rnc_acao 
UNION all SELECT rnc_EFICACIA.data  , rnc_EFICACIA.emitente, rnc_EFICACIA.rnc_n, rnc_EFICACIA.pendencia, rnc_EFICACIA.responsavel, rnc_EFICACIA.prazo, rnc_eficacia.item, rnc_eficacia.nome, rnc_eficacia.entidade, rnc_eficacia.mail
FROM RNC_EFICACIA union ALL
select x.data, x.emitente, x.rnc_n, x.pendencia, x.responsavel, x.prazo, x.item, x.nome, x.entidade, x.mail
from rnc_complementar x
;



/* View: RNC_GERAL_PENDENTE */
CREATE VIEW RNC_GERAL_PENDENTE(
    MAIL)
AS
select a.mail
from rnc_geral a group by mail
;



/* View: ROMANEIO */
CREATE VIEW ROMANEIO(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    RAZAO,
    VALORTOTALNF,
    PEDIDOCLI,
    STAEST,
    CFOP,
    NFRECUSA)
AS
select numnf, emissao, sistema, codcli, fantasia, valortotalnf, pedidocli, staest, cfop, nfrecusa
from tbnfc where staest = 1
;



/* View: ROMANEIO_ENT */
CREATE VIEW ROMANEIO_ENT(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    RAZAO,
    CNPJ,
    VALORTOTALNF,
    PEDIDOCLI,
    STAEST,
    BASEICMS,
    VALORICMS,
    VALORIPI,
    BASEICMSSUBST,
    VALORICMSSUBST,
    VALORITENS,
    VALORISS,
    VALORSERVICO,
    VALORFRETE,
    VALORSEGURO,
    OUTRASDEPESAS,
    COMISSAOEXT,
    IDNUMNF,
    CCTOT,
    CENTROS,
    PROJETO,
    NFCFOPI,
    UNIDADE,
    VEND,
    NOMEVEND)
AS
select numnf, emissao, sistema, tbnfc.codcli, tbnfc.fantasia,tbnfc.cnpjcli,  tbnfc.valortotalnf , tbnfc.pedidocli, staest,
baseicms, valoricms, valoripi, baseicmssubst, valoricmssubst, valoritens, valoriss, valorservico, valorfrete, valorseguro, outrasdepesas,
COMISSAOEXT,idnumnf, sum(vltot),
cc1 ||'/'|| cc2||'/'||cc3||'/'||cc4||'/'||cc5,
FORMAENV, tbnfc.nfcfopi, tbnfc.unidade, tbnfc.vend, tbnfc.nomevend 
from tbnfc left join (tbitensnfc left join proj_ped on (iditemped = iditem))
on (numnf = idnumnf) group by numnf, emissao, sistema, tbnfc.codcli, tbnfc.fantasia,tbnfc.cnpjcli,  valortotalnf, tbnfc.pedidocli, staest,
baseicms, valoricms, valoripi, baseicmssubst, valoricmssubst, valoritens, valoriss, valorservico, valorfrete, valorseguro, outrasdepesas,
COMISSAOEXT, idnumnf,
cc1 ||'/'|| cc2||'/'||cc3||'/'||cc4||'/'||cc5,
FORMAENV, tbnfc.nfcfopi, tbnfc.unidade, tbnfc.vend, tbnfc.nomevend
;



/* View: ROMANEIO_TECNO */
CREATE VIEW ROMANEIO_TECNO(
    NUMNF,
    EMISSAO,
    SISTEMA,
    CODCLI,
    RAZAO,
    VALORTOTALNF,
    PEDIDOCLI,
    STAEST,
    BASEICMS,
    VALORICMS,
    VALORIPI,
    BASEICMSSUBST,
    VALORICMSSUBST,
    VALORITENS,
    VALORISS,
    VALORSERVICO,
    VALORFRETE,
    VALORSEGURO,
    OUTRASDEPESAS,
    COMISSAOEXT,
    IDNUMNF,
    CCTOT,
    CENTROS,
    PROJETO,
    NFCFOPI,
    DESCCFOP)
AS
select numnf, emissao, sistema, tbnfc.codcli, tbnfc.fantasia, tbnfc.valortotalnf , tbnfc.pedidocli, staest,
baseicms, valoricms, valoripi, baseicmssubst, valoricmssubst, valoritens, valoriss, valorservico, valorfrete, valorseguro, outrasdepesas,
COMISSAOEXT,idnumnf, sum(vltot),
cc1 ||'/'|| cc2||'/'||cc3||'/'||cc4||'/'||cc5,
FORMAENV, tbnfc.nfcfopi, tbnfc.desccfop
from tbnfc left join (tbitensnfc left join proj_ped on (iditemped = iditem))
on (numnf = idnumnf) group by numnf, emissao, sistema, tbnfc.codcli, tbnfc.fantasia, valortotalnf, tbnfc.pedidocli, staest,
baseicms, valoricms, valoripi, baseicmssubst, valoricmssubst, valoritens, valoriss, valorservico, valorfrete, valorseguro, outrasdepesas,
COMISSAOEXT, idnumnf,
cc1 ||'/'|| cc2||'/'||cc3||'/'||cc4||'/'||cc5,
FORMAENV, tbnfc.nfcfopi, tbnfc.desccfop  having (tbnfc.staest = 1 and tbnfc.codcli = 1916)
;



/* View: ROTEIRO_PROCESSO */
CREATE VIEW ROTEIRO_PROCESSO(
    ARVORE,
    IDPROC,
    TIPO,
    SEQ,
    VR_CUSTO,
    PRODUTO)
AS
select fluxo_processo.arvore, fluxo_processo.idarvproc, 0, fluxo_processo.seq,  fluxo_processo.vroper, fluxo_processo.produto
from fluxo_processo order by arvore, seq, idarvproc
;



/* View: SAIDACFOP */
CREATE VIEW SAIDACFOP(
    CFOP,
    DESCCFOP,
    SAIDA,
    EMISSAO,
    NOTAFISCAL,
    FORNECEDOR,
    VALORITENS,
    BASEICMS,
    ALIQICMS,
    VALORICMS,
    BASEICMSSUBST,
    VALORICMSSUBST,
    ALIQIPI,
    VALORIPI,
    VALORFRETE,
    VALORSERVICO,
    VALORSEGURO,
    OUTRSDESPESAS,
    VALORTOTAL,
    CANC)
AS
select a.cfop, a.desccfop, a.sistema, a.emissao,  a.nf_numero, a.razao, a.valoritens, a.baseicms, a.icms, a.valoricms,
a.baseicmssubst, a.valoricmssubst,
case when a.valoritens = 0 then 0
else
cast(f_round((a.valoripi/a.valoritens)*100) as numeric(12,2))
end, a.valoripi, a.valorfrete, a.valorservico,
a.valorseguro, a.outrasdepesas, a.valortotalnf,
a.canc
from tbnf a
where a.sistema >= '01.01.2012'
;



/* View: SALDO_ENTRADA_MP */
CREATE VIEW SALDO_ENTRADA_MP(
    CODCLI,
    CODIGOITEM,
    QTDE,
    NF_NUMERO,
    VLUNIT)
AS
select codcli, codigoitem, sum(qtde), nf_numero , vlunit
from movimento_mp
group by codcli, codigoitem, nf_numero, vlunit
having sum(qtde) > 0
;



/* View: SALDO_FINAL */
CREATE VIEW SALDO_FINAL(
    LOTE,
    PRODUTO,
    QTDE,
    MES,
    ANO,
    STATUS,
    MES_LANC,
    TIPO_ITEM)
AS
select lote, codigomat, sum(qtd_mov),f_left(mes_lanc,2),f_right(mes_lanc,4), 'SALDO FINAL', mes_lanc, movimento.tipo_item
from movimento where movimento.grupo in (0,1,2) GROUP BY lote,
codigomat,
f_left(mes_lanc,2),f_right(mes_lanc,4), 'SALDO FINAL', mes_lanc, movimento.tipo_item
having (tipo_item in('MAT�RIA-PRIMA','COMPONENTE FABRICADO','COMPONENTE COMPRADO','PRODUTO ACABADO') and sum(qtd_mov)> 0)
order by codigomat, mes_lanc
;



/* View: SALDO_ITEM */
CREATE VIEW SALDO_ITEM(
    NPED,
    CODMAT,
    PEND,
    ST)
AS
select
idnumped,
codprod,
sum(saldo),
status
from tbpropitem group by idnumped,codprod,status
having (status =0) order by codprod
;



/* View: SALDO_LOTES */
CREATE VIEW SALDO_LOTES(
    CODIGO,
    TIPO,
    SALDO,
    RESERVADO,
    INSPECAO,
    COMPRA,
    TERCEIRO,
    PROCESSO)
AS
select tblote.codigoitem, tblote.tipo,
case
when sum(tblote.saldolote) is null then 0
else sum(tblote.saldolote)
end,
case when sum(tblote.qtde_reserv) is null then 0
else sum(tblote.qtde_reserv)
end,
case when sum(tblote.qtde_insp) is null then 0
else sum(tblote.qtde_insp)
end,
case when sum(tblote.qtde_prog) is null then 0
else sum(tblote.qtde_prog)
end,
case when sum(tblote.qtde_terc) is null then 0
else sum(tblote.qtde_terc)
end,
case when sum(tblote.qtde_proc) is null then 0
else sum(tblote.qtde_proc)
end
from tblote where tipo =0
group by codigoitem, tipo order by codigoitem
;



/* View: SALDO_PED */
CREATE VIEW SALDO_PED(
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    ST,
    STPREV,
    VEND,
    NOMEVEND,
    VLORIG,
    VLTOTAL,
    IPITOT,
    IPIORIG,
    PRAZO)
AS
select numped,codcli, fantasia, cpag, st, stprev, vend, nomevend, sum(vlitem), sum(vlfaturar), sum(vtotipi),sum(voripi),prazo
from pedido group by numped, codcli, fantasia, cpag, st,stprev, vend, nomevend,
prazo having ((pedido.st) = 4 and (pedido.stprev) =0)
;



/* View: SALDO_PEDC */
CREATE VIEW SALDO_PEDC(
    CONTATO,
    UNIDADE,
    NUMPED,
    CODCLI,
    FANTASIA,
    CPAG,
    ST,
    STPREV,
    VEND,
    NOMEVEND,
    VLORIG,
    VLTOTAL,
    IPITOT,
    IPIORIG,
    PRAZO)
AS
select pedidoc.contato, pedidoc.unidade,   numped,codcli, fantasia, cpag, st, stprev, vend, nomevend, sum(vlitem), sum(vlfaturar), sum(vtotipi),sum(voripi),prazo
from pedidoc where prazo >= '01.06.2010' group by pedidoc.contato, pedidoc.unidade, numped, codcli, fantasia, cpag, st,stprev, vend, nomevend,
prazo having ((pedidoc.st) = 4 and (pedidoc.stprev) =0)
;



/* View: VERFATURA_ENTRADAS */
CREATE VIEW VERFATURA_ENTRADAS(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    ESTAGIO,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    VALORMOV,
    NATUREZADOC,
    CODDESP,
    DATAMOV,
    CARTEIRA,
    BANCO,
    IDMOV,
    STATUS,
    ULTREV,
    ALTPOR,
    GERADO,
    FORMPAG,
    REG,
    FLAG,
    DESCCONTA,
    PEDIDOS,
    DESCRICAO_EVENTO,
    ANO,
    MES)
AS
select idpagrec, dataemiss, tbfor.tbforraz, tipo, codforcli, estagio, docto, seqdoc, totseqdoc,
case when cartorio
is not null then cartorio
else
datavenc
end ,
valordoc , naturezadoc, coddesp, ENTRADA,
carteira, banco, idmov, status, pagrec.ultrev, altpor, gerado, formpag, reg, flag,
pagrec.descconta, pedidos, 'ENTRADA', cast(F_PADleft(f_year(ENTRADA),'0',4) as varchar(4)), cast(F_PADleft(f_MONTH(ENTRADA),'0',2) as varchar(2))
from pagrec left join contas on (pagrec.coddesp = contas.codconta)
left join tbfor on (pagrec.codforcli = tbfor.tbforcod) where entrada >='01.01.2012' and pagrec.tipo in (0,1)
;



/* View: VERFATURA_EVENTOS */
CREATE VIEW VERFATURA_EVENTOS(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    ESTAGIO,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    VALORMOV,
    NATUREZADOC,
    CODDESP,
    DATAMOV,
    CARTEIRA,
    BANCO,
    IDMOV,
    STATUS,
    FORMPAG,
    REG,
    FLAG,
    DESCCONTA,
    PEDIDOS,
    DESCRICAO_EVENTO,
    ANO,
    MES)
AS
select idpagrec, dataemiss, tbfor.tbforraz, tipo, codforcli, estagio, docto, seqdoc, totseqdoc,
case when cartorio
is not null then cartorio
else
datavenc
end ,
case when faturas_eventos.tipo_evento is null
then 0
else
case WHEN faturas_eventos.tipo_evento = 0
THEN faturas_eventos.valor_informado * -1
ELSE faturas_eventos.valor_informado
END
end
, naturezadoc, coddesp, faturas_eventos.datapgto,

carteira, banco, idmov, status, formpag, reg, flag,
CONTAS.nomeconta, pedidos, faturas_eventos.nome_evento, cast(F_PADleft(f_year(DATAPGTO),'0',4) as varchar(4)), cast(F_PADleft(f_MONTH(DATAPGTO),'0',2) as varchar(2))
from faturas_eventos left join contas on (faturas_eventos.coddesp = contas.codconta)
left join tbfor on (faturas_eventos.codforcli = tbfor.tbforcod) where faturas_eventos.datapgto >= '01.01.2012'
and faturas_eventos.tipo in (0,1)
;



/* View: VERFATURA_SAIDAS */
CREATE VIEW VERFATURA_SAIDAS(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    ESTAGIO,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    VALORMOV,
    NATUREZADOC,
    CODDESP,
    DATAMOV,
    CARTEIRA,
    BANCO,
    IDMOV,
    STATUS,
    ULTREV,
    ALTPOR,
    GERADO,
    FORMPAG,
    REG,
    FLAG,
    DESCCONTA,
    PEDIDOS,
    DESCRICAO_EVENTO,
    ANO,
    MES)
AS
select idpagrec, dataemiss, tbfor.tbforraz, tipo, codforcli, estagio, docto, seqdoc, totseqdoc,
case when cartorio
is not null then cartorio
else
datavenc
end ,
PAGREC.valorpgto * -1, naturezadoc, coddesp, PAGREC.datapgto,
carteira, banco, idmov, status, pagrec.ultrev, altpor, gerado, formpag, reg, flag,
pagrec.descconta, pedidos, 'PAGAMETO', cast(F_PADleft(f_year(DATAPGTO),'0',4) as varchar(4)), cast(F_PADleft(f_MONTH(DATAPGTO),'0',2) as varchar(2))
from pagrec left join contas on (pagrec.coddesp = contas.codconta)
left join tbfor on (pagrec.codforcli = tbfor.tbforcod)
where pagrec.datapgto >= '01.01.2012' and pagrec.tipo in (0,1)
;



/* View: VERFATURA_CONSOLIDADA */
CREATE VIEW VERFATURA_CONSOLIDADA(
    IDPAGREC,
    DATAEMISS,
    DESCR,
    TIPO,
    CODFORCLI,
    ESTAGIO,
    DOCTO,
    SEQDOC,
    TOTSEQDOC,
    DATAVENC,
    VALORMOV,
    NATUREZADOC,
    CODDESP,
    DATAMOV,
    CARTEIRA,
    BANCO,
    IDMOV,
    STATUS,
    FORMPAG,
    REG,
    FLAG,
    DESCCONTA,
    PEDIDOS,
    DESCRICAO_EVENTO,
    ANO,
    MES)
AS
select en.idpagrec, en.dataemiss, en.descr, en.tipo, en.codforcli, en.estagio, en.docto, en.seqdoc, en.totseqdoc, en.datavenc, en.valormov, en.naturezadoc, en.coddesp, en.datamov, en.carteira, en.banco, en.idmov, en.status, en.formpag, en.reg, en.flag, en.descconta, en.pedidos, en.descricao_evento, en.ano, en.mes
from verfatura_entradas en union all
select ev.idpagrec, ev.dataemiss, ev.descr, ev.tipo, ev.codforcli, ev.estagio, ev.docto, ev.seqdoc, ev.totseqdoc, ev.datavenc, ev.valormov, ev.naturezadoc, ev.coddesp, ev.datamov, ev.carteira, ev.banco, ev.idmov, ev.status, ev.formpag, ev.reg, ev.flag, ev.descconta, ev.pedidos, ev.descricao_evento, ev.ano, ev.mes
from verfatura_eventos ev union all
select sa.idpagrec, sa.dataemiss, sa.descr, sa.tipo, sa.codforcli, sa.estagio, sa.docto, sa.seqdoc, sa.totseqdoc, sa.datavenc, sa.valormov, sa.naturezadoc, sa.coddesp, sa.datamov, sa.carteira, sa.banco, sa.idmov, sa.status, sa.formpag, sa.reg, sa.flag, sa.descconta, sa.pedidos, sa.descricao_evento, sa.ano, sa.mes
from verfatura_saidas sa
;



/* View: SALDOS_FINANCEIRO */
CREATE VIEW SALDOS_FINANCEIRO(
    ANO,
    MES,
    CODFOR,
    NOME,
    SALDO)
AS
select verfatura_consolidada.ano,  verfatura_consolidada.mes, 
verfatura_consolidada.codforcli, verfatura_consolidada.descr,
sum(verfatura_consolidada.valormov) as saldo from verfatura_consolidada
group by verfatura_consolidada.ano,  verfatura_consolidada.mes, 
verfatura_consolidada.codforcli, verfatura_consolidada.descr
order by verfatura_consolidada.codforcli, verfatura_consolidada.ano,
verfatura_consolidada.mes
;



/* View: SALDOS_MENORES */
CREATE VIEW SALDOS_MENORES(
    ITEM_NF,
    QTD_KG,
    OS_NF,
    PESO_LIQ,
    PECAS_NF,
    OS_PROCESSO,
    QTD_PROCESSO,
    STATUS_OS)
AS
select tbitensnf.codigoitem, tbitensnf.qt_os , tbitensnf.n_os ,
tbitens.pesoliqitem, cast(tbitensnf.qt_os/tbitens.pesoliqitem as numeric(15,0)),
tb_os.numero_os, tb_os.saldo, tb_os.status from tbitensnf
left join tbitens on (tbitensnf.codigoitem = tbitens.codigoitem)
left join tb_os on (tbitensnf.n_os = tb_os.numero_os)
where tbitensnf.idnumnf = 102845 order by tbitensnf.codigoitem
;



/* View: SALDOS_MENORES_SAIDA */
CREATE VIEW SALDOS_MENORES_SAIDA(
    ITEM_NF,
    QTD_KG,
    OS_NF,
    PESO_LIQ,
    PECAS_NF,
    OS_PROCESSO,
    QTD_PROCESSO,
    STATUS_OS)
AS
select tbitensnf.codigoitem, tbitensnf.qt_os , tbitensnf.n_os ,
tbitens.pesoliqitem, cast(tbitensnf.qt_os/tbitens.pesoliqitem as numeric(15,0)),
tb_os.numero_os, tb_os.saldo, tb_os.status from tbitensnf
left join tbitens on (tbitensnf.codigoitem = tbitens.codigoitem)
left join tb_os on (tbitensnf.n_os = tb_os.numero_os)
where tbitensnf.idnumnf = 102868 order by tbitensnf.codigoitem
;



/* View: SEM_DESENHO */
CREATE VIEW SEM_DESENHO(
    CODIGOITEM,
    NOMEITEM,
    DESENHOITEM,
    REVDESENHOITEM)
AS
select codigoitem, nomeitem, desenhoitem, revdesenhoitem from tbitens
;



/* View: SEM_FATURA */
CREATE VIEW SEM_FATURA(
    NOTA_FISCAL,
    FORNECEDOR,
    SUBCFOP,
    GERA_FATURA,
    CFOP,
    DESCCFOP,
    EMISSAO,
    ENTRADA,
    VALOR,
    FATURA,
    VENCIMENTO,
    VALORDOC,
    SALDO)
AS
select tbnfc.pedidocli, tbnfc.razao,tbnfc.nfcfopi ,case
when  tbcfop.geradupl = 0 then 'S'
else
'N'
end , tbnfc.cfop, tbnfc.desccfop,
tbnfc.emissao, tbnfc.sistema, tbnfc.valortotalnf,
pagrec.idpagrec, pagrec.datavenc , pagrec.valordoc , pagrec.saldo 
from tbnfc left join pagrec on (tbnfc.pedidocli = pagrec.docto) left join tbcfop on nfcfopi = cfopi
where tbcfop.geradupl = 0
;



/* View: SEM_REGISTRO */
CREATE VIEW SEM_REGISTRO(
    CODIGO,
    STATUS,
    CODFOR,
    NUMNF)
AS
select codigoitem, staest, codcli, numnf  from tbnfc join tbitensnfc on (numnf = idnumnf)
where staest = 0
;



/* View: SEM_VINCULO */
CREATE VIEW SEM_VINCULO(
    ESTRUTURA,
    PRODUTO,
    CODIGOITEM,
    DESTINO,
    SEQ,
    IDPROC,
    ESTRUTURA_VINC,
    INCONSISTENCIA)
AS
select a.arvore, a.produto, a.codigoitem, cast(a.destino as numeric(15,0)),
b.seq, b.idarvproc , b.arvore,
case when
a.arvore <> b.arvore 
then 'Destino Inv�lido'
when
b.idarvproc is null
then 'Destino n�o Especificado'
else
'Validado'
end
from tbarvoremat a left join tbarvoreproc b
on (cast(a.destino as numeric(15,0)) = b.idarvproc)
;



/* View: SETORES_2 */
CREATE VIEW SETORES_2(
    GRUPO,
    NOME_GRUPO,
    MAQUINA,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    NCC,
    CAPTOTDIA,
    CAPTOTMES,
    CAPT1,
    CAPT2,
    CAPT3,
    CAPTDISP,
    TIPO)
AS
select distinct c.idccusto, c.nome, a.idrec, a.nomerec, b.idsetor, b.nomesetor, b.ncc, a.capdisp,
((a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs))*a.dias_disp_mes,

a.t1realhs, a.t2realhs, a.t3realhs ,

((a.t1capqtd * a.t1caphs)+
(a.t2capqtd * a.t2caphs)+
(a.t3capqtd * a.t3caphs))*a.dias_tot_mes, c.tipomo



 from tb_recurso a
left join tbsetor b on (a.idsetor = b.idsetor)
LEFT JOIN ccusto c on (b.idccusto = c.idccusto)
;



/* View: SOMA_DIARIA_PARADAS */
CREATE VIEW SOMA_DIARIA_PARADAS(
    DATA,
    MAQUINA,
    PARADAS,
    TURNO)
AS
select
a.data, 
a.maquina,
sum(a.total),
a.turno
from horas_paradas a
group by
a.data, 
a.maquina,
a.turno
;



/* View: SOMA_GRADE_INSPECAO */
CREATE VIEW SOMA_GRADE_INSPECAO(
    ID,
    DATA_INSPECAO,
    CODIGO,
    OPERACAO,
    INSPECAO,
    APROVADO,
    REPROVADO,
    CONCESSAO,
    RETRABALHO,
    SELECAO,
    SUCATA)
AS
select 1, data_INSPECAO, codigo, operacao, sum(INSPECAO), sum(aprovado),  sum(reprovado), SUM(CONCESSAO), sum(retrabalho), sum(selecao), sum(sucata) from
grade_inspecao
group by 1, data_INSPECAO, codigo, operacao
;



/* View: TOTAL_PARADAS_MAQUINA */
CREATE VIEW TOTAL_PARADAS_MAQUINA(
    DATA,
    MAQUINA,
    PARADA1,
    PARADA2,
    PARADA3)
AS
select a.data, maquina,
coalesce((select sum(b.paradas) from soma_diaria_paradas b where b.turno = 1 and b.data = a.data and b.maquina = a.maquina),0),
coalesce((select sum(b.paradas) from soma_diaria_paradas b where b.turno = 2 and b.data = a.data and b.maquina = a.maquina),0),
coalesce((select sum(b.paradas) from soma_diaria_paradas b where b.turno = 3 and b.data = a.data and b.maquina = a.maquina),0)
from soma_diaria_paradas a
group by data, maquina
;



/* View: TOTAIS_MAQUINA */
CREATE VIEW TOTAIS_MAQUINA(
    DATA,
    CODIGO,
    SETOR,
    OPERACAO,
    MAQUINA,
    QTDE1,
    QTDE2,
    QTDE3,
    PCHORA,
    TURNO1,
    TURNO2,
    TURNO3,
    PARADAS_1,
    PARADAS_2,
    PARADAS_3,
    TRAB1,
    TRAB2,
    TRAB3)
AS
select
a.data,
a.codigo,
a.setor,
a.operacao,
a.maquina,
case when a.turno = 1
then a.qtde else 0
end, 
case when a.turno = 2
then a.qtde else 0
end, 
case when a.turno = 3
then a.qtde else 0
end, 
a.pchora,

case when a.turno = 1 then
a.turno1 else 0 end,
case when a.turno = 2 then
a.turno2 else 0 end,
case when a.turno = 3 then
a.turno3 else 0 end,




coalesce (b.parada1,0),
coalesce (b.parada2,0),
coalesce (b.parada3,0),

case when a.turno = 1  and a.qtde > 0 then
coalesce(a.turno1 - coalesce(b.parada1,0),0) else 0 end,

case when a.turno = 2  and a.qtde > 0 then
coalesce(a.turno2 - coalesce(b.parada2,0),0) else 0 end,

case when a.turno = 3  and a.qtde > 0 then
coalesce(a.turno3 - coalesce(b.parada3,0),0) else 0 end

from apontamentos_producao a
left join total_paradas_maquina b on (a.data = b.data and a.maquina = b.maquina)



order by a.data, a.setor, a.codigo, a.maquina, a.turno, a.operacao
;



/* View: SOMA_TOTAIS_MAQUINA */
CREATE VIEW SOMA_TOTAIS_MAQUINA(
    DATA,
    CODIGO,
    SETOR,
    OPERACAO,
    MAQUINA,
    PCHORA,
    QTDE1,
    TURNO1,
    TRAB1,
    QTDE2,
    TURNO2,
    TRAB2,
    QTDE3,
    TURNO3,
    TRAB3)
AS
select data, codigo, setor, operacao, maquina,  pchora, sum(qtde1),
case when sum(qtde1) = 0
then 0
else
sum(turno1)
end,
sum(a.trab1),
sum(qtde2),
case when sum(qtde2) = 0 then 0
else
sum(turno2)
end, sum(a.trab2),
sum(qtde3),
case when sum(qtde3) = 0
then 0 else
sum(turno3)
end, sum(a.trab3)
from totais_MAQUINA a
group by data, codigo, setor, operacao, maquina, pchora order by data,codigo, maquina
;



/* View: TOTAIS_TURNO */
CREATE VIEW TOTAIS_TURNO(
    DATA,
    CODIGO,
    SETOR,
    OPERACAO,
    MAQUINA,
    QTDE1,
    QTDE2,
    QTDE3,
    PCHORA,
    TURNO1,
    TURNO2,
    TURNO3,
    PCSTURNO)
AS
select
a.data,
a.codigo,
a.setor,
a.operacao,
a.maquina,
case when a.turno = 1
then a.qtde else 0
end, 
case when a.turno = 2
then a.qtde else 0
end, 
case when a.turno = 3
then a.qtde else 0
end, 
a.pchora,

case when a.turno = 1 then
a.turno1 else 0 end,
case when a.turno = 2 then
a.turno2 else 0 end,
case when a.turno = 3 then
a.turno3 else 0 end /*,




coalesce (b.parada1,0),
coalesce (b.parada2,0),
coalesce (b.parada3,0),

case when a.turno = 1  and a.qtde > 0 then
coalesce(a.turno1 - coalesce(b.parada1,0),0) else 0 end,

case when a.turno = 2  and a.qtde > 0 then
coalesce(a.turno2 - coalesce(b.parada2,0),0) else 0 end,

case when a.turno = 3  and a.qtde > 0 then
coalesce(a.turno3 - coalesce(b.parada3,0),0) else 0 end*/ , PCSTURNO

from apontamentos_valor a
/*left join total_paradas_maquina b on (a.data = b.data and a.maquina = b.maquina)*/
where a.evento = 'PRODUCAO'
order by a.data, a.setor, a.codigo, a.maquina, a.turno, a.operacao
;



/* View: SOMA_TOTAIS_TURNO */
CREATE VIEW SOMA_TOTAIS_TURNO(
    DATA,
    CODIGO,
    SETOR,
    OPERACAO,
    MAQUINA,
    PCHORA,
    QTDE1,
    TURNO1,
    QTDE2,
    TURNO2,
    QTDE3,
    TURNO3,
    PCSTURNO)
AS
select data, codigo, setor, operacao, maquina,  pchora, sum(qtde1),
case when sum(qtde1) = 0
then 0
else
max(turno1)
end,
/*sum(a.trab1),*/
sum(qtde2),
case when sum(qtde2) = 0 then 0
else
max(turno2)
end, /*sum(a.trab2), */
sum(qtde3),
case when sum(qtde3) = 0
then 0 else
max(turno3)
end, /*sum(a.trab3), */PCSTURNO
from totais_TURNO a
group by data, codigo, setor, operacao, maquina,  pchora,  PCSTURNO order by data,codigo, maquina
;



/* View: VALORES_TURNO */
CREATE VIEW VALORES_TURNO(
    DATA,
    CODIGO,
    OS,
    OPERACAO,
    MES_ENTREGA,
    QTDE1,
    VALOR1,
    QTDE2,
    VALOR2,
    QTDE3,
    VALOR3)
AS
select
a.data,
a.codigo,
a.os, 
a.operacao,
a.mes_extenso,
case when a.turno = 1
then a.qtde else 0
end, 
case when a.turno = 1
then a.valor_lote else 0
end, 
case when a.turno = 2
then a.qtde else 0
end, 
case when a.turno = 2
then a.valor_lote else 0
end, 
case when a.turno = 3
then a.qtde else 0
end, 
case when a.turno = 3
then a.valor_lote else 0
end
from apontamentos_valor a

where a.operacao = 'AT1' and a.evento ='PRODUCAO' order by a.data, a.codigo, a.operacao, a.mes_extenso
;



/* View: SOMA_VALORES_TURNO */
CREATE VIEW SOMA_VALORES_TURNO(
    DATA,
    CODIGO,
    OS,
    OPERACAO,
    MES_ENTREGA,
    QTDE1,
    VALOR1,
    QTDE2,
    VALOR2,
    QTDE3,
    VALOR3)
AS
select data, codigo, os, operacao, mes_entrega, sum(qtde1), sum(valor1), sum(qtde2), sum(valor2), sum(qtde3), sum(valor3)
from valores_turno
group by data, codigo, os, operacao, mes_entrega order by data,codigo,os
;



/* View: TIPO_ET */
CREATE VIEW TIPO_ET(
    ET,
    TIPO,
    DESCRTIPO)
AS
select et, tipo, descrtipo from tbet join tbtipoet on (tipo = tipoet)
;



/* View: TOTAIS_FATURADOS */
CREATE VIEW TOTAIS_FATURADOS(
    CODIGOMAT,
    OS,
    QTDE,
    VALOR_BRUTO,
    UND,
    LOTE,
    CFOP,
    CODFOR,
    CANC,
    UF,
    ICMS,
    MES_LANC,
    TIPO_ITEM,
    ALIQICMS,
    ALIQIPI,
    PERC_ICMS,
    TRIB_PISCOFINS,
    ALIQ_PIS,
    ALIQ_COFINS,
    IMPOSTOS,
    VALOR_LIQUIDO)
AS
select a.codigomat, a.os, sum(a.qtdsaida), a.valorlanc, a.und, a.lote, a.cfop, a.codfor, b.canc, b.tbforest,
case when
c.aliqicms = 0 then d.aliqpjcont
else 0
end,  a.mes_lanc, a.tipo_item,
c.aliqicms, c.aliqipi, c.perc_icms, c.trib_piscofins,
case when
c.trib_piscofins = 0 then c.aliq_pis
else 0
end,
case when
c.trib_piscofins = 0 then c.aliq_cofins
else 0
end,
case when
c.aliqicms = 0 and c.trib_piscofins = 0 then
d.aliqpjcont + c.aliq_pis + c.aliq_cofins
when
c.aliqicms = 0 and c.trib_piscofins = 1 then
d.aliqpjcont
when
c.aliqicms = 1 and c.trib_piscofins = 0 then
c.aliq_pis + c.aliq_cofins
end,

case when
c.aliqicms = 0 and c.trib_piscofins = 0 then
cast((1-((d.aliqpjcont + c.aliq_pis + c.aliq_cofins)/100))*a.valorlanc as digito4)
when
c.aliqicms = 0 and c.trib_piscofins = 1 then
cast((1-(d.aliqpjcont/100))*a.valorlanc as digito4)
when
c.aliqicms = 1 and c.trib_piscofins = 0 then
cast((1-((c.aliq_pis + c.aliq_cofins)/100))*a.valorlanc as digito4)
end




from movimento_faturado a left join (tbnf b left join tbicms d on (b.tbforest = d.uf_icms)) on (cast(a.nota_fiscal as numero4) = b.nf_numero and a.codfor = b.codcli)
left join tbcfop c on (a.cfop = c.cfopi)
where b.canc = 'N'
group by a.codigomat, a.os, a.valorlanc, a.und, a.lote, a.cfop, a.codfor, B.canc, b.tbforest,
case when
c.aliqicms = 0 then d.aliqpjcont
else 0
end,  a.mes_lanc, a.tipo_item,
c.aliqicms, c.aliqipi, c.perc_icms, c.trib_piscofins,
case when
c.trib_piscofins = 0 then c.aliq_pis
else 0
end,
case when
c.trib_piscofins = 0 then c.aliq_cofins
else 0
end,
case when
c.aliqicms = 0 and c.trib_piscofins = 0 then
d.aliqpjcont + c.aliq_pis + c.aliq_cofins
when
c.aliqicms = 0 and c.trib_piscofins = 1 then
d.aliqpjcont
when
c.aliqicms = 1 and c.trib_piscofins = 0 then
c.aliq_pis + c.aliq_cofins
end,
case when
c.aliqicms = 0 and c.trib_piscofins = 0 then
cast((1-((d.aliqpjcont + c.aliq_pis + c.aliq_cofins)/100))*a.valorlanc as digito4)
when
c.aliqicms = 0 and c.trib_piscofins = 1 then
cast((1-(d.aliqpjcont/100))*a.valorlanc as digito4)
when
c.aliqicms = 1 and c.trib_piscofins = 0 then
cast((1-((c.aliq_pis + c.aliq_cofins)/100))*a.valorlanc as digito4)
end
;



/* View: TOTAIS_IMPOSTOS_NF_SAIDA */
CREATE VIEW TOTAIS_IMPOSTOS_NF_SAIDA(
    NF_NUMERO,
    CODCLI,
    SISTEMA,
    VALOR_ICMS,
    VALOR_IPI,
    VALOR_PIS,
    VALOR_COFINS)
AS
select a.numero_nf, a.codcli, a.sistema,  sum(a.valor_icms), sum(a.valor_ipi), sum(a.valor_pis), sum(a.valor_cofins) from notas_fiscais_se222 a
group by a.numero_nf, a.codcli, a.sistema
;



/* View: TOTAIS_SETORES */
CREATE VIEW TOTAIS_SETORES(
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    RECURSO,
    DISP_MES,
    ANO_SOLIC,
    MES_OM,
    REF_MAQ)
AS
select b.mes_ano, a.grupo, a.nome_grupo, a.maquina,
a.captotmes, b.ano, b.mes, B.mes_ano||A.maquina
from setores a cross join dcalendario b
group by b.mes_ano, a.grupo, a.nome_grupo, a.maquina,
a.captotmes, b.ano, b.mes, B.mes_ano||A.maquina
order by a.grupo, a.maquina, b.ano, b.mes
;



/* View: TOTAL_ETIQ_MP */
CREATE VIEW TOTAL_ETIQ_MP(
    PRODUTO,
    LOTE,
    OS,
    SALDO,
    TIPO)
AS
select produto, lote, os , saldo, tipo
from tb_inv_est group by produto, lote, os, saldo, tipo
having tb_inv_est.tipo = 0
;



/* View: TOTAL_ETIQ_PROC */
CREATE VIEW TOTAL_ETIQ_PROC(
    PRODUTO,
    SALDO,
    TIPO)
AS
select produto, SUM(saldo), tipo
from tb_inv_est GROUP BY  produto, tipo
HAVING (TIPO = 'PR')
;



/* View: TOTAL_INVENTARIO */
CREATE VIEW TOTAL_INVENTARIO(
    PRODUTO,
    QTDE,
    VRTOTAL,
    UNITARIO,
    MES,
    ANO,
    STATUS,
    LOTE,
    OS,
    TIPO,
    TIPO_ITEM)
AS
select produto, SUM(qtde) , SUM(vrtotal) , unitario, mes, ano, status, LOTE, os, tipo, TIPO_ITEM
from lotes_inventario
GROUP BY produto, unitario, mes, ano, status, LOTE,os, tipo, TIPO_ITEM
;



/* View: TOTAL_INVENTARIO_PR */
CREATE VIEW TOTAL_INVENTARIO_PR(
    PRODUTO,
    QTDE,
    VRTOTAL,
    UNITARIO,
    MES,
    ANO,
    STATUS,
    OS,
    TIPO,
    TIPO_ITEM)
AS
select produto, SUM(qtde) , SUM(vrtotal) , unitario, mes, ano, status, OS, tipo, TIPO_ITEM
from lotes_inventario_PR
GROUP BY produto, unitario, mes, ano, status, OS, tipo, TIPO_ITEM
;



/* View: TOTAL_PEDC */
CREATE VIEW TOTAL_PEDC(
    NUMPED,
    CODCLI,
    FANTASIA,
    ST,
    STPREV,
    VLORIG,
    VLTOTAL,
    IPITOT,
    IPIORIG)
AS
select numped,codcli, fantasia, st, stprev, sum(vlitem), sum(vlfaturar), sum(vtotipi),sum(voripi)
from pedidoc group by numped, codcli, fantasia, st,stprev
having ((pedidoc.st) = 4 and (pedidoc.stprev) =0)
;



/* View: TOTAL_RECEBIDO */
CREATE VIEW TOTAL_RECEBIDO(
    CODIGOITEM,
    QTDEITEM,
    VLITEM,
    FATORCONVITEM,
    MES_BASE,
    ANO_BASE)
AS
select
codigoitem, cast(sum(qtdeitem)*fatorconvitem as numeric(12,4)), cast(sum(vlitem) as numeric (12,4)), fatorconvitem, mes_base, ano_base
from notas_recebidas
group by codigoitem, fatorconvitem, mes_base, ano_base
;



/* View: TOTAL_RESUMO_PRODUCAO */
CREATE VIEW TOTAL_RESUMO_PRODUCAO(
    DT_MOVTO,
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM,
    HS_TRAB_1,
    HS_PAR_1,
    TEMPO_LIQ_1,
    REAL_1,
    PREV_1,
    QTD_LIQ_1,
    HS_TRAB_2,
    HS_PAR_2,
    TEMPO_LIQ_2,
    REAL_2,
    PREV_2,
    QTD_LIQ_2,
    HS_TRAB_3,
    HS_PAR_3,
    TEMPO_LIQ_3,
    REAL_3,
    PREV_3,
    QTD_LIQ_3,
    MAQUINA)
AS
select
 A.DATA AS DT_MOVTO,
    A.MES,
    A.ANO,




a.setor,
a.setor_roteiro,
a.produto,
a.operacao,
a.ciclo_roteiro,
a.ciclo_maquina,
a.cc,

CASE WHEN
a.cc_roteiro = 136 THEN 106
WHEN
a.cc_roteiro = 133 THEN 103
WHEN
a.cc_roteiro = 132 THEN 102
ELSE
a.cc_roteiro
END as CC_ROTEIRO,

A.ordem,
SUM(A.hs_trab1) AS HS_TRAB_1,
SUM(A.hs_paradas1) AS HS_PAR_1,
SUM(A.tempo_liq1) AS TEMPO_LIQ_1,
sum(a.realizado1) as REAL_1,
SUM(A.previsto1) AS PREV_1,

SUM(case when a.ciclo_roteiro > 0 then
cast(a.tempo_liq1 * 3600 / A.ciclo_roteiro as int)
else
0
end) as QTD_LIQ_1,

SUM(A.hs_trab2) AS HS_TRAB_2,
SUM(A.hs_paradas2) AS HS_PAR_2,
SUM(A.tempo_liq2) AS TEMPO_LIQ_2,
sum(a.realizado2) as REAL_2,
SUM(A.previsto2) AS PREV_2,

SUM(case when a.ciclo_roteiro > 0 then
cast(a.tempo_liq2 * 3600 / a.ciclo_ROTEIRO as int)
else
0
end) as QTD_LIQ_2,

SUM(A.hs_trab3) AS HS_TRAB_3,
SUM(A.hs_paradas3) AS HS_PAR_3,
SUM(A.tempo_liq3) AS TEMPO_LIQ_3,
sum(a.realizado3) as REAL_3,
SUM(A.previsto3) AS PREV_3 ,

SUM(case when a.ciclo_roteiro > 0 then
cast(a.tempo_liq3 * 3600 / a.ciclo_ROTEIRO as int)
else
0
end) as QTD_LIQ_3  ,

a.maquina 

from resumo_producao a where A.ordem <> 999 AND A.ano >= 2022
group by
a.data,
a.mes,
a.ano,
a.setor,
a.setor_roteiro,
a.produto,
a.operacao,
a.ciclo_roteiro,
a.ciclo_maquina,
a.cc,
a.cc_roteiro, A.ordem , a.maquina
;



/* View: TOTAL_RESUMO_PRODUCAO_GERAL */
CREATE VIEW TOTAL_RESUMO_PRODUCAO_GERAL(
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM,
    HS_TRAB_1,
    HS_PAR_1,
    TEMPO_LIQ_1,
    REAL_1,
    PREV_1,
    QTD_LIQ_1,
    HS_TRAB_2,
    HS_PAR_2,
    TEMPO_LIQ_2,
    REAL_2,
    PREV_2,
    QTD_LIQ_2,
    HS_TRAB_3,
    HS_PAR_3,
    TEMPO_LIQ_3,
    REAL_3,
    PREV_3,
    QTD_LIQ_3,
    HS_TRAB_TOTAL,
    HS_PAR_TOTAL,
    TEMPO_LIQ_TOTAL,
    REAL_TOTAL,
    PREV_TOTAL,
    QTD_LIQ_TOTAL)
AS
SELECT
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM,
    SUM(HS_TRAB_1) AS HS_TRAB_1,
    SUM(HS_PAR_1) AS HS_PAR_1,
    SUM(TEMPO_LIQ_1) AS TEMPO_LIQ_1,
    SUM(REAL_1) AS REAL_1,
    SUM(PREV_1) AS PREV_1,
    SUM(QTD_LIQ_1) QTD_LIQ_1,
    SUM(HS_TRAB_2) AS HS_TRAB_2,
    SUM(HS_PAR_2) AS HS_PAR_2,
    SUM(TEMPO_LIQ_2) AS TEMPO_LIQ_2,
    SUM(REAL_2) AS REAL_2,
    SUM(PREV_2) AS PREV_2,
    SUM(QTD_LIQ_2) AS QTD_LIQ_2,
    SUM(HS_TRAB_3) AS HS_TRAB_3,
    SUM(HS_PAR_3) AS HS_PAR_3,
    SUM(TEMPO_LIQ_3) AS TEMPO_LIQ_3,
    SUM(REAL_3) AS REAL_3,
    SUM(PREV_3) AS PREV_3,
    SUM(QTD_LIQ_3) AS QTD_LIQ_3,

    SUM(HS_TRAB_1)+SUM(HS_TRAB_2)+SUM(HS_TRAB_3) AS HS_TRAB_TOTAL,
    SUM(HS_PAR_1)+SUM(HS_PAR_2)+SUM(HS_PAR_3) AS HS_PAR_TOTAL,
    SUM(TEMPO_LIQ_1)+SUM(TEMPO_LIQ_2)+SUM(TEMPO_LIQ_3) AS TEMPO_LIQ_TOTAL,
    SUM(REAL_1)+SUM(REAL_2)+SUM(REAL_3) AS REAL_TOTAL,
    SUM(PREV_1)+SUM(PREV_2)+SUM(PREV_3) AS PREV_TOTAL,
    SUM(QTD_LIQ_1)+SUM(QTD_LIQ_2)+SUM(QTD_LIQ_3) QTD_LIQ_TOTAL

FROM total_resumo_producao a WHERE a.dt_movto>='01.03.2022'
GROUP by
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM
;



/* View: TOTAL_RESUMO_PRODUCAO_MES */
CREATE VIEW TOTAL_RESUMO_PRODUCAO_MES(
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM,
    MAQUINA,
    HS_TRAB_1,
    HS_PAR_1,
    TEMPO_LIQ_1,
    REAL_1,
    PREV_1,
    QTD_LIQ_1,
    HS_TRAB_2,
    HS_PAR_2,
    TEMPO_LIQ_2,
    REAL_2,
    PREV_2,
    QTD_LIQ_2,
    HS_TRAB_3,
    HS_PAR_3,
    TEMPO_LIQ_3,
    REAL_3,
    PREV_3,
    QTD_LIQ_3,
    HS_TRAB_TOTAL,
    HS_PAR_TOTAL,
    TEMPO_LIQ_TOTAL,
    REAL_TOTAL,
    PREV_TOTAL,
    QTD_LIQ_TOTAL)
AS
SELECT
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM, MAQUINA,
    SUM(HS_TRAB_1) AS HS_TRAB_1,
    SUM(HS_PAR_1) AS HS_PAR_1,
    SUM(TEMPO_LIQ_1) AS TEMPO_LIQ_1,
    SUM(REAL_1) AS REAL_1,
    SUM(PREV_1) AS PREV_1,
    SUM(QTD_LIQ_1) QTD_LIQ_1,
    SUM(HS_TRAB_2) AS HS_TRAB_2,
    SUM(HS_PAR_2) AS HS_PAR_2,
    SUM(TEMPO_LIQ_2) AS TEMPO_LIQ_2,
    SUM(REAL_2) AS REAL_2,
    SUM(PREV_2) AS PREV_2,
    SUM(QTD_LIQ_2) AS QTD_LIQ_2,
    SUM(HS_TRAB_3) AS HS_TRAB_3,
    SUM(HS_PAR_3) AS HS_PAR_3,
    SUM(TEMPO_LIQ_3) AS TEMPO_LIQ_3,
    SUM(REAL_3) AS REAL_3,
    SUM(PREV_3) AS PREV_3,
    SUM(QTD_LIQ_3) AS QTD_LIQ_3,

    SUM(HS_TRAB_1)+SUM(HS_TRAB_2)+SUM(HS_TRAB_3) AS HS_TRAB_TOTAL,
    SUM(HS_PAR_1)+SUM(HS_PAR_2)+SUM(HS_PAR_3) AS HS_PAR_TOTAL,
    SUM(TEMPO_LIQ_1)+SUM(TEMPO_LIQ_2)+SUM(TEMPO_LIQ_3) AS TEMPO_LIQ_TOTAL,
    SUM(REAL_1)+SUM(REAL_2)+SUM(REAL_3) AS REAL_TOTAL,
    SUM(PREV_1)+SUM(PREV_2)+SUM(PREV_3) AS PREV_TOTAL,
    SUM(QTD_LIQ_1)+SUM(QTD_LIQ_2)+SUM(QTD_LIQ_3) QTD_LIQ_TOTAL

FROM total_resumo_producao a WHERE a.dt_movto>='01.03.2022' and A.dt_movto BETWEEN DATEADD(day,-7,current_date) AND current_date
GROUP by
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM, MAQUINA
;



/* View: TOTAL_SETORES */
CREATE VIEW TOTAL_SETORES(
    GRUPO,
    NOME_GRUPO,
    CAPTOTMES,
    TIPO)
AS
select c.idccusto, c.nome,
SUM(((a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs))*a.dias_disp_mes),
c.tipomo
from tbrecurso a
left join tbsetor b on (a.idsetor = b.idsetor)
LEFT JOIN ccusto c on (b.idccusto = c.idccusto)
WHERE C.tipomo = 'MOD'
GROUP BY C.idccusto, C.nome, C.tipomo
;



/* View: TOTALIZA_CUSTO */
CREATE VIEW TOTALIZA_CUSTO(
    ARVORE,
    IDPROC,
    TIPO,
    SEQ,
    VR_CUSTO,
    PRODUTO)
AS
select arvore, idproc, tipo, seq, vr_custo, produto
from roteiro_processo
union all
select arvore, idproc, tipo, seq, vr_custo, produto
from lista_materiais
;



/* View: ULT_ENTRADA */
CREATE VIEW ULT_ENTRADA(
    DATA,
    CODCLI,
    FANTASIA,
    CODIGO,
    UND,
    PRECO,
    ET_PED,
    TIPO,
    STR_ET)
AS
select max(sistema), codcli, fantasia, codigoitem, und, max(vlunit), n_et,
tbet.tipo,  'ET'||n_et||'/'||tbet.tipo 
 from notas_trat join tbet on (notas_trat.n_et = tbet.et)
 group by codcli, fantasia, codigoitem, und, n_et,
tbet.tipo,  'ET'||n_et||'/'||tbet.tipo having tbet.tipo <> 'MP'
;



/* View: ULTIMA_AUDITORIA_PRODUTO */
CREATE VIEW ULTIMA_AUDITORIA_PRODUTO(
    CODIGO,
    PRAZO)
AS
select a.item, max(a.prazo)from tb_auditoria_produto a
group by a.item
;



/* View: ULTIMA_NOTA_VDA */
CREATE VIEW ULTIMA_NOTA_VDA(
    COD_ENTIDADE,
    ID_AUDITORIA,
    ID_REGISTRO,
    NOTA_AVALIACAO,
    STATUS_AVALIACAO,
    PROX_AUDITORIA,
    INDICE_SISTEMA,
    CALCULO_IQF)
AS
select cod_entidade, a.id_auditoria, MAX(id_registro), nota_avaliacao, status_avaliacao, prox_auditoria,
case when
current_date <= prox_auditoria then
case
when status_avaliacao = 'A' then 30
when status_avaliacao = 'B' then 10
when status_avaliacao = 'C' then 0
else 0
end
else 0
end, calculo_iqf
from tb_auditoria a left join tb_tipo_auditoria b on (a.id_auditoria = b.id_auditoria) WHERE calculo_iqf = 1 AND STATUS_AVALIACAO <> 'PENDENTE'
GROUP BY  cod_entidade, id_auditoria, nota_avaliacao, status_avaliacao, prox_auditoria, calculo_iqf
;



/* View: ULTIMA_PREVENTIVA */
CREATE VIEW ULTIMA_PREVENTIVA(
    ULTIMA_DATA,
    OM,
    RECURSO,
    TIPO_MANUT,
    STATUS,
    ENCERRADA,
    PERIODICIDADE,
    PROXIMA)
AS
select max(a.data_programada), max(a.n_cont)  ,a.recurso, a.tipo_manut, a.status, max(a.data_encerrada), b.periodicidade_manutencao,
f_addday(max(a.data_programada),b.periodicidade_manutencao)
from tb_om a left join tbrecurso b on (a.recurso = b.idrec)
where tipo_manut = 2 and a.data_programada is not null and a.recurso is not null and status = 4
group by a.recurso, a.tipo_manut, a.status, b.periodicidade_manutencao
;



/* View: ULTIMAS_ENTRADAS */
CREATE VIEW ULTIMAS_ENTRADAS(
    ID,
    CODIGO,
    STATUS,
    TIPO_ITEM)
AS
select MAX(notasfiscaisc.iditemnf),
notasfiscaisc.codigoitem, notasfiscaisc.status, notasfiscaisc.tipo_item 
FROM NOTASFISCAISC where tipo_item in ('MAT�RIA-PRIMA','COMPONENTE COMPRADO') AND STATUS = 0
group by
notasfiscaisc.codigoitem, notasfiscaisc.STATUS, notasfiscaisc.tipo_item
;



/* View: ULTIMO_FORNECIMENTO */
CREATE VIEW ULTIMO_FORNECIMENTO(
    DATA,
    CODFOR,
    RAZAO,
    TIPO,
    SITUACAO)
AS
select max(sistema), tbforcod, tbfor.tbforraz, tbfor.tbforq,
case
when f_ageindays(max(sistema),current_date) >= 365 then 1
when max(sistema) is null then 1
else 0
end
from tbfor left join tbnfc on (tbfor.tbforcod = tbnfc.codcli  ) group by tbforcod, tbforraz, tbforq
having tbforq in (0,1,2, 3)
;



/* View: ULTIMO_IQF */
CREATE VIEW ULTIMO_IQF(
    CODFOR,
    BASE)
AS
select b.iqfforcod, max(b.iqfano||b.iqfnmes)
from iqf b group by b.iqfforcod
;



/* View: UNIDADES */
CREATE VIEW UNIDADES(
    CODIGOITEM,
    NOMEITEM,
    UNDCOMPRAITEM,
    UNDUSOITEM,
    FATORCONVITEM)
AS
select codigoitem, nomeitem, undcompraitem, undusoitem, fatorconvitem from tbitens
where grupoitem in ('01','11','16','18','20') order by codigoitem
;



/* View: V_PED */
CREATE VIEW V_PED(
    NUMPED,
    PRIPED,
    PRAZOCOT,
    CC2)
AS
select NUMPED,PRIPED,PRAZOCOT,
f_replace(f_right(PRAZOCOT,9),'.','')
 from TBPROPC
where f_stringlength(PRAZOCOT) = 29
;



/* View: V_PED2 */
CREATE VIEW V_PED2(
    NUMPED,
    PRIPED,
    PRAZOCOT,
    CC2)
AS
select NUMPED,PRIPED,PRAZOCOT,
f_replace(f_right(PRAZOCOT,9),'.','')
 from TBPROPC
 WHERE prazocot is not null
;



/* View: VER_ET */
CREATE VIEW VER_ET(
    ET,
    TIPO,
    CODIGO,
    DESCRCODIGO)
AS
select et, tipo, codigo, descrcodigo from tbet
;



/* View: VERITEM */
CREATE VIEW VERITEM(
    CODIGOITEM,
    NOMEITEM,
    DESENHOITEM,
    REVDESENHOITEM,
    CODFATURAMITEM,
    UNDCOMPRAITEM,
    UNDUSOITEM,
    FATORCONVITEM,
    GRUPOITEM,
    GRUPOCONTAB,
    ICMSITEMVENDA,
    IPIITEMVENDA,
    SITTRIBITEM,
    CLASSFISCALITEM,
    PESOBRITEM,
    PESOLIQITEM,
    PESOESPEITEM,
    COMPRIMITEM,
    LARGURAITEM,
    ESPESSURAITEM,
    ALTURAITEM,
    PRECOVENDA,
    PRECOCOMPRA,
    TABELAICMSITEM,
    ICMSITEMCOMPRA,
    IPIITEMCOMPRA,
    VALORMEDIOITEM,
    VALORCUSTOITEM,
    VALORULTCOMPRA,
    DATAULTCOMPRA,
    VALORULTVENDA,
    DATAULTVENDA,
    MARKUPITEM,
    COMISSAOVENITEM,
    COMISSAOREPITEM,
    COMISSAOINTITEM,
    COMISSAOEXTITEM,
    DESCCOMERCITEM,
    CUSTOMATITEM,
    CUSTOTRATITEM,
    CUSTOPROCITEM,
    CUSTOACABITEM,
    AREAITEM,
    PERIMETROITEM,
    CICLOREPITEM,
    ESTOQUEMINITEM,
    ESTOQUEMAXITEM,
    ESTOQUEPROGITEM,
    ESTOQUECOMPITEM,
    ESTOQUEFISICOITEM,
    ESTOQUEDISPITEM,
    LOCALARMAZITEM,
    RUAARMAZITEM,
    PRATELEIRAITEM,
    INSPECIONAITEM,
    MOVESTOQUE,
    CICLOPRODDITEM,
    ACABAMENTOITEM,
    ESPECIFCAMITEM,
    CAMMINIMAITEM,
    CAMMAXIMAITEM,
    EXIGECAMITEM,
    TIPOITEM,
    CODIGOPAIITEM,
    DESTINOITEM,
    OBSCOMERCITEM,
    OBSTECNICAITEM,
    INCLUSAO,
    DATAREVDES,
    PCSHORA,
    SETUPHS,
    ORIGEMITEM,
    CODPROD,
    REFITEM,
    NATPROD,
    REVPROC,
    DATAREVPROC,
    CNC,
    REVCNC,
    DATAREVCNC,
    ARQUIVO,
    DESCCOMPRA,
    DIAMITEM,
    CODCLITEM,
    NOMECLITEM,
    REVCUSTO,
    USERCUSTO,
    REFCUSTO,
    ULTFORN,
    ESTOQUESERVITEM,
    ESTOQUEPROCITEM,
    FATORCONVEN,
    UNDVENDA)
AS
select codigoitem, nomeitem, desenhoitem, revdesenhoitem, codfaturamitem, undcompraitem, undusoitem, fatorconvitem, grupoitem, grupocontab, icmsitemvenda, ipiitemvenda, sittribitem, classfiscalitem, pesobritem, pesoliqitem, pesoespeitem, comprimitem, larguraitem, espessuraitem, alturaitem, precovenda, precocompra, tabelaicmsitem, icmsitemcompra, ipiitemcompra, valormedioitem, valorcustoitem, valorultcompra, dataultcompra, valorultvenda, dataultvenda, markupitem, comissaovenitem, comissaorepitem, comissaointitem, comissaoextitem, desccomercitem, customatitem, custotratitem, custoprocitem, custoacabitem, areaitem, perimetroitem, ciclorepitem, estoqueminitem, estoquemaxitem, estoqueprogitem, estoquecompitem, estoquefisicoitem, estoquedispitem, localarmazitem, ruaarmazitem, prateleiraitem, inspecionaitem, movestoque, cicloprodditem, acabamentoitem, especifcamitem, camminimaitem, cammaximaitem, exigecamitem, tipoitem, codigopaiitem, destinoitem, obscomercitem, obstecnicaitem, inclusao, datarevdes,
pcshora, setuphs, origemitem, codprod, refitem, natprod, revproc, datarevproc, cnc, revcnc, datarevcnc, arquivo, desccompra,diamitem,codclitem, nomeclitem,revcusto, usercusto, refcusto, ultforn, estoqueservitem, estoqueprocitem, fatorconven, undvenda
 from tbitens
;



/* View: VIEW_EGA_OF */
CREATE VIEW VIEW_EGA_OF(
    OS,
    PRODUTO,
    OPERACAO,
    PCHORA,
    PCCICLO,
    QUANTIDADE)
AS
select a.numero_os, a.produto, b.seq, b.pchora, b.undoper,
case when
a.saldo <= 0 then a.qtde_produzir
else
a.saldo
end from tb_os a left join fluxo_processo b
on (a.estrutura = b.arvore) where b.custo = 1 and b.pchora > 0
;



/* View: VIEW_FMEA */
CREATE VIEW VIEW_FMEA(
    USUARIO,
    PRODUTO,
    DATA_FMEA,
    ANO_MODELO_PROG,
    RESPONSABILIDADE,
    EQUIPE_CENTRAL,
    ELABORACAO,
    TIPO_FMEA,
    DATA_REVISAO,
    APLIC_CODIGO,
    APLIC_IDFMEA,
    IDPROC,
    FUNCAO_OPERACAO,
    FUNCAO_DESCRICAO,
    IDFEMEA,
    DATA_CHAVE,
    FUNCAO_OBJETIVO,
    FALHA_ID,
    FALHA_IDFMEA,
    FALHA_DESCRICAO,
    FALHA_CARACTERISTICA,
    FALHA_ITEM,
    FALHA_CARACT_ESP,
    EFEITO_ID,
    EFEITO_FALHA_ID,
    EFEITO_DESCRICAO,
    EFEITO_SEVERIDADE,
    EFEITO_CLASS,
    EFEITO_ID_FMEA,
    CAUSA_ID,
    CAUSA_EFEITO_ID,
    CAUSA_DESCRICAO,
    CAUSA_OCORRENCIA,
    CAUSA_DETECCAO,
    CAUSA_NPR,
    CAUSA_ID_FMEA,
    CONTROLE_ID,
    CONTROLE_CAUSA_ID,
    CONTROLE_PREVENCAO,
    CONTROLE_DETECCAO,
    CONTROLE_ID_FMEA,
    ACAO_ID,
    ACAO_CONTROLE_ID,
    ACAO_RECOMENDADA,
    ACAO_RESPONSAVEL,
    ACAO_PRAZO,
    ACAO_ADOTADA,
    ACAO_DATAEFETIVA,
    ACAO_SEVERIDADE,
    ACAO_OCORRENCIA,
    ACAO_DETECCAO,
    ACAO_NPR,
    ACAO_ID_FMEA)
AS
select a.usuario, a.produto, a.data_fmea, a.ano_modelo_prog, a.responsabilidade, a.equipe_central, a.elaboracao, a.tipo_fmea, a.data_revisao,
a.aplic_codigo, a.aplic_idfmea, a.aplic_idproc, a.funcao_operacao, a.funcao_descricao, a.idfemea,
a.data_chave, a.funcao_objetivo,
a.falha_id, a.falha_idfmea, a.falha_descricao, a.falha_caracteristica, a.falha_item, a.falha_caract_esp,
a.efeito_id, a.efeito_falha_id, a.efeito_descricao, a.efeito_severidade, a.efeito_class, a.efeito_id_fmea,
a.causa_id, a.causa_efeito_id, a.causa_descricao, a.causa_ocorrencia, a.causa_deteccao, a.causa_npr, a.causa_id_fmea,
a.controle_id, a.controle_causa_id, a.controle_prevencao, a.controle_deteccao, a.controle_id_fmea,
a.acao_id, a.acao_controle_id, a.acao_recomendada, a.acao_responsavel, a.acao_prazo, a.acao_adotada, a.acao_dataefetiva, a.acao_severidade, a.acao_ocorrencia, a.acao_deteccao,
a.acao_npr, a.acao_id_fmea
from report_fmea a order by a.funcao_operacao
;



/* View: VIQF */
CREATE VIEW VIQF(
    IQFBASE,
    IQFFORCOD,
    IQFPPM,
    IQFPONTOS,
    IQFPERC,
    IQFIQEPERC,
    IQFIQEPONTOS,
    IQFPONTFINAL,
    IQFAPP,
    IQFAPVAL,
    IQFREDUTOR,
    IQFAFP,
    IQFAFVAL,
    IQFPPMAC,
    IQFSIT,
    IQFCERT,
    IQFAPV,
    IQFAFV,
    IQFLOTESTOTAL,
    IQFLOTESAPROV,
    IQFLOTESDESVIO,
    IQFLOTESUSAR,
    IQFLOTESAFETA,
    IQFLOTESREJ,
    IQFTOTALENT,
    IQFTOTALREJ,
    IQFSTATUS,
    IQFAP,
    IQFOBS,
    IQFANO,
    IQFNMES,
    TBFORFAN,
    TBFORCERT,
    TBFORVALIDADE,
    TBFORUND,
    TBFORNATFOR,
    TBFOROBS,
    STATUS)
AS
select iqfbase, iqfforcod, iqfppm, iqfpontos, iqfperc, iqfiqeperc, iqfiqepontos, iqfpontfinal, iqfapp, iqfapval, iqfredutor, iqfafp, iqfafval, iqfppmac, iqfsit, iqfcert, iqfapv, iqfafv, iqflotestotal, iqflotesaprov, iqflotesdesvio, iqflotesusar, iqflotesafeta, iqflotesrej, iqftotalent, iqftotalrej,iqfstatus, iqfap, iqfobs,iqfano,iqfnmes, tbforfan, tbforcert, tbforvalidade,tbforund,tbfornatfor,tbforobs,
case tbfor.tbforq 
when 0 then 'NÃO QUALIFICADO'
when 1 then 'QUALIFICADO'
when 2 then 'DESENVOLVIMENTO'
when 3 then 'NÃO APLIC�VEL'  else 'NÃO APLIC�VEL'
end
from
iqf join tbfor on(iqfforcod=tbfor.tbforcod)
;



/* View: VIQFTRIM */
CREATE VIEW VIQFTRIM(
    IQFBASETRIM,
    IQFFORCOD,
    IQFPPM,
    IQFPONTOS,
    IQFPERC,
    IQFIQEPERC,
    IQFIQEPONTOS,
    IQFPONTFINAL,
    IQFAPP,
    IQFAPVAL,
    IQFREDUTOR,
    IQFAFP,
    IQFAFVAL,
    IQFPPMAC,
    IQFSIT,
    IQFCERT,
    IQFAPV,
    IQFAFV,
    IQFLOTESTOTAL,
    IQFLOTESAPROV,
    IQFLOTESDESVIO,
    IQFLOTESUSAR,
    IQFLOTESAFETA,
    IQFLOTESREJ,
    IQFTOTALENT,
    IQFTOTALREJ,
    IQFSTATUS,
    IQFAP,
    IQFOBS,
    IQFANO,
    IQFNMES,
    TBFORFAN,
    TBFORCERT,
    TBFORVALIDADE,
    TBFORUND,
    TBFORNATFOR,
    TBFOROBS,
    STATUS)
AS
select iqfbasetrim, iqfforcod, iqfppm, iqfpontos, iqfperc, iqfiqeperc, iqfiqepontos, iqfpontfinal, iqfapp, iqfapval, iqfredutor, iqfafp, iqfafval, iqfppmac, iqfsit, iqfcert, iqfapv, iqfafv, iqflotestotal, iqflotesaprov, iqflotesdesvio, iqflotesusar, iqflotesafeta, iqflotesrej, iqftotalent, iqftotalrej,iqfstatus, iqfap, iqfobs, iqfano, iqfnmes, tbforfan, tbforcert, tbforvalidade,tbforund,tbfornatfor,tbforobs,
case tbfor.tbforq 
when 0 then 'NÃO QUALIFICADO'
when 1 then 'QUALIFICADO'
when 2 then 'DESENVOLVIMENTO'
when 3 then 'NÃO APLIC�VEL'  else 'NÃO APLIC�VEL'
end
from
iqftrim  join tbfor on(iqfforcod=tbfor.tbforcod)
;



/* View: VMOV2 */
CREATE VIEW VMOV2(
    IDMOV,
    DATAMOV,
    DESCMOV,
    IDBANCO,
    VALOR,
    TIPO,
    MEIOPGTO,
    CHEQUE,
    OBS,
    ENTRADA,
    SAIDA,
    SALDO,
    REGBANCO,
    NOMEBANCO,
    CODIGOBANCO,
    AGENCIA,
    NUMCONTA,
    TIPOCONTA,
    FATURAS)
AS
select idmov, datamov, descmov,movimento_fin.idbanco,  valor, tipo, meiopgto,cheque, obs, entrada, saida, saldo, regbanco, nomebanco,codigobanco, agencia, numconta, tipoconta, faturas
  from movimento_fin left join tbbancos  on (movimento_fin.idbanco = tbbancos.idbanco)
;



/* View: VW_AN_MANUTENCAO */
CREATE VIEW VW_AN_MANUTENCAO(
    REGISTRO,
    NOME,
    HORAS,
    DIA,
    MES,
    ANO,
    JORNADA,
    OM,
    DESCRICAO_OCORRENCIA,
    DESCRICAO_SERVICO,
    STATUS)
AS
SELECT registro, nome, 0 as HORAS, DIA, MES, ANO, jornada, 0 as OM, ' ' AS DECRICAO_OCORRENCIA, ' ' AS DESCRICAO_SERVICO, 0 AS STATUS
FROM HORAS_REPARO_POR_OPERADOR
group by registro, nome, dia, mes, ano, jornada
---order by registro, dia
UNION ALL
SELECT registro, nome, tempo as HORAS, DIA, MES, ANO, 0 as jornada,NUMERO_OM AS OM,  DESCRICAO_OCORRENCIA, DESCRICAO_SERVICO, 1 AS STATUS
FROM HORAS_REPARO_POR_OPERADOR
--order by registro, dia
;



/* View: VW_APONTADOS */
CREATE VIEW VW_APONTADOS(
    DT_MOVTO,
    MAQUINA,
    TURNO,
    HS_DISP,
    ANO,
    MES,
    CC,
    NOME_MAQUINA,
    TIPO_MAQUINA,
    NOME_TIPO_MAQUINA,
    SETOR,
    NOME_SETOR)
AS
select A.data AS DT_MOVTO,
A.maquina AS MAQUINA,
A.turno AS TURNO,
case
WHEN A.turno = 1 THEN B.capt1
WHEN A.turno = 2 THEN B.capt2
WHEN A.turno = 3 THEN B.capt3
END AS HS_DISP,
f_year(a.data) AS ANO,
f_month(a.data) AS MES ,
b.ncc AS CC,
b.nome_maquina AS NOME_MAQUINA,
b.setor  AS TIPO_MAQUINA,
b.nome_setor as NOME_TIPO_MAQUINA,
b.grupo AS SETOR,
b.nome_grupo AS NOME_SETOR



from tb_apontamento A

left join vw_setores B
on (a.maquina = B.maquina and f_month(a.data) = f_month(B.dt_posicao) and f_year(a.data) = f_year(B.dt_posicao))
WHERE A.data >='01.01.2022'
GROUP BY A.data, A.maquina, A.turno,
case
WHEN A.turno = 1 THEN B.capt1
WHEN A.turno = 2 THEN B.capt2
WHEN A.turno = 3 THEN B.capt3
END ,
f_year(a.data),
f_month(a.data),
b.ncc,
b.nome_maquina,
b.setor,
b.nome_setor,
b.grupo,
b.nome_grupo
;



/* View: VW_APONTADOS_PARADAS */
CREATE VIEW VW_APONTADOS_PARADAS(
    DT_MOVTO,
    MAQUINA,
    TURNO,
    TEMPO)
AS
select A.data AS DT_MOVTO,
A.maquina AS MAQUINA,
A.turno AS TURNO,
SUM(A.tempo) AS TEMPO
from tb_apontamento A
WHERE A.data >='01.01.2022' AND A.lancamento <> 1
GROUP BY A.data, A.maquina, A.turno
;



/* View: VW_APONTADOS_QTD */
CREATE VIEW VW_APONTADOS_QTD(
    DT_MOVTO,
    MAQUINA,
    TURNO,
    ORDEM,
    CODIGO,
    OPERACAO,
    OPERADOR,
    CICLO_ROTEIRO,
    CC_ROTEIRO,
    CICLO_MAQ,
    SETOR_ROTEIRO,
    SETUP_ROTEIRO,
    QTDE)
AS
select A.data AS DT_MOVTO,
A.maquina AS MAQUINA,
A.turno AS TURNO,
A.ordem AS ORDEM,
A.codigo AS CODIGO,
A.operacao AS OPERACAO,
A.operador AS OPERADOR,
coalesce(d.ciclo,0) as CICLO_ROTEIRO,
COALESCE(d.cc_roteiro,'') AS CC_ROTEIRO ,
COALESCE(d.ciclo_maq,0) AS CICLO_MAQ,

d.nome AS SETOR_ROTEIRO,
d.setup AS SETUP_ROTEIRO,

SUM(A.quantidade) AS QTDE
from tb_apontamento A
left join tb_of_ciclo d on (a.ordem = d.ordem and
case when cast(a.operacao as integer) = 0
then 20
else
cast(a.operacao as integer) end = d.seq)
WHERE A.data >='01.01.2022' AND A.lancamento = 1 and a.quantidade > 0
GROUP BY A.data, A.maquina, A.turno, A.ordem, A.codigo, A.operacao, A.operador,
coalesce(d.ciclo,0),
COALESCE(d.cc_roteiro,''),
COALESCE(d.ciclo_maq,0),
d.nome,
d.setup
;



/* View: VW_CRITICA_PRODUCAO */
CREATE VIEW VW_CRITICA_PRODUCAO(
    MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM,
    MAQUINA,
    HS_TRAB_1,
    HS_PAR_1,
    TEMPO_LIQ_1,
    REAL_1,
    PREV_1,
    QTD_LIQ_1,
    HS_TRAB_2,
    HS_PAR_2,
    TEMPO_LIQ_2,
    REAL_2,
    PREV_2,
    QTD_LIQ_2,
    HS_TRAB_3,
    HS_PAR_3,
    TEMPO_LIQ_3,
    REAL_3,
    PREV_3,
    QTD_LIQ_3,
    HS_TRAB_TOTAL,
    HS_PAR_TOTAL,
    TEMPO_LIQ_TOTAL,
    REAL_TOTAL,
    PREV_TOTAL,
    QTD_LIQ_TOTAL,
    FORA_SETOR,
    FORA_CICLO,
    FORA_PLANO)
AS
select MES,
    ANO,
    SETOR,
    SETOR_ROTEIRO,
    PRODUTO,
    OPERACAO,
    CICLO_ROTEIRO,
    CICLO_MAQUINA,
    CC,
    CC_ROTEIRO,
    ORDEM,
    MAQUINA,
    HS_TRAB_1,
    HS_PAR_1,
    TEMPO_LIQ_1,
    REAL_1,
    PREV_1,
    QTD_LIQ_1,
    HS_TRAB_2,
    HS_PAR_2,
    TEMPO_LIQ_2,
    REAL_2,
    PREV_2,
    QTD_LIQ_2,
    HS_TRAB_3,
    HS_PAR_3,
    TEMPO_LIQ_3,
    REAL_3,
    PREV_3,
    QTD_LIQ_3,
    HS_TRAB_TOTAL,
    HS_PAR_TOTAL,
    TEMPO_LIQ_TOTAL,
    REAL_TOTAL,
    PREV_TOTAL,
    QTD_LIQ_TOTAL,

case
when
cast(a.cc as int) <> a.cc_roteiro AND A.REAL_TOTAL > 0
then 1
else 0
end as FORA_SETOR,

CASE WHEN
A.ciclo_maquina > A.ciclo_roteiro AND A.REAL_TOTAL > 0 and a.ciclo_maquina - a.ciclo_roteiro >= 2
THEN 1
ELSE 0
END AS FORA_CICLO,

CASE
    when a.real_total >= 0 and a.qtd_liq_total > 0 then
    case when a.real_total / a.qtd_liq_total < 0.8 then
        1
        else
        0
    end
 else
0

END AS FORA_PLANO

FROM
total_resumo_producao_MES a
;



/* View: VW_RECURSOS */
CREATE VIEW VW_RECURSOS(
    MAQUINA,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    CAPT1,
    CAPT2,
    CAPT3,
    CAPTOTDIA,
    CAPTOTMES,
    GRUPO,
    TIPO,
    NOME_GRUPO,
    POSICAO)
AS
select a.idrec, a.nomerec, b.idsetor, b.nomesetor,
a.t1realqtd * a.t1realhs,
a.t2realqtd * a.t2realhs,
a.t3realqtd * a.t3realhs,

(a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs),

((a.t1realqtd * a.t1realhs)+
(a.t2realqtd * a.t2realhs)+
(a.t3realqtd * a.t3realhs))*a.dias_disp_mes,

c.idccusto, c.tipomo, C.nome, A.dt_posicao




from tb_recurso a left join tbsetor b on (a.idsetor = b.idsetor)
left join ccusto c on (b.idccusto = c.idccusto)
order by a.idrec
;



/* View: VW_HORAS_MANUTENCAO */
CREATE VIEW VW_HORAS_MANUTENCAO(
    OM,
    DATA_SOLICITACAO,
    HORA_SOLICITACAO,
    DATA_PROGRAMADA,
    HORA_PROGRAMADA,
    DATA_ENCERRADA,
    HORA_ENCERRADA,
    DATA_ANDAMENTO,
    HORA_ANDAMENTO,
    STATUS,
    TIPO_MANUT,
    OBS_TIPO_MANUT,
    NATUREZA_MANUT,
    OBS_NATUREZA_MANUT,
    DESCRICAO_OCORRENCIA,
    SETOR_SOLICITANTE,
    RECURSO,
    OPERADOR,
    OS_VINCULADA,
    SOLICITANTE,
    DESCRICAO_SERVICO,
    CHECK_LIST_VINCULADO,
    INFO_COMPLEMENTAR,
    N_CONT,
    DEFEITO,
    PRAZO_TECNICO,
    DATA_FINAL,
    MINUTOS_PARADOS,
    DESCRICAO_NATUREZA,
    DESCRICAO_TIPO,
    DESCRICAO_STATUS,
    DESCRICAO_MAQUINA,
    DESCRICAO,
    TEMPO_GASTO,
    TEMPO_REPARO,
    DISP_MES,
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    ANO_SOLIC,
    MES_OM,
    REF_MAQ,
    OM_ORIGEM,
    DATA_ORIGEM,
    NOME_GRUPO,
    PRIORIDADE,
    TIPO_M)
AS
select distinct a.om, a.data_solicitacao, a.hora_solicitacao, a.data_programada, a.hora_programada, a.data_encerrada, a.hora_encerrada,
a.data_andamento, a.hora_andamento, a.status, a.tipo_manut,
a.obs_tipo_manut, a.natureza_manut, a.obs_natureza_manut,
a.descricao_ocorrencia, a.setor_solicitante, a.recurso, a.codigo, a.os_vinculada, cast(a.solicitante as int), a.descricao_servico,
a.check_list_vinculado, a.info_complementar, CAST(a.n_cont AS INT),
case
when a.defeito is null then 'NA'
else
a.defeito
end,
a.prazo_tecnico,
f_lastdaymonth(a.data_solicitacao),
case
when a.data_encerrada is null then
        case
        when f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(f_left(f_lastdaymonth(a.data_solicitacao),10)|| ' 23:59' as timestamp)) is null then 0
        else f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(f_left(f_lastdaymonth(a.data_solicitacao),10)|| ' 23:59' as timestamp))
        end
else
        case
        when f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(a.data_encerrada || ' ' || a.hora_encerrada as timestamp)) is null then 0
        else f_minutesbetween(cast(a.data_solicitacao || ' ' || a.hora_solicitacao as timestamp), cast(a.data_encerrada || ' ' || a.hora_encerrada as timestamp))
        end
END ,
case
when a.natureza_manut = 1 then 'INDUSTRIAL'
when a.natureza_manut = 2 then 'FERRAMENTARIA'
when a.natureza_manut = 3 then 'SERVI�OS DE TERCEIRO'
when a.natureza_manut = 4 then 'OUTROS'
END,
CASE
WHEN a.TIPO_MANUT = 1 THEN 'CORRETIVA'
WHEN a.TIPO_MANUT = 2 THEN 'PREVENTIVA'
WHEN a.TIPO_MANUT = 3 THEN 'MPT'
WHEN a.TIPO_MANUT = 4 THEN 'OUTROS'
WHEN a.TIPO_MANUT = 5 THEN 'OUTROS'
WHEN a.TIPO_MANUT = 6 THEN 'OUTROS'
END,
CASE
WHEN a.STATUS = 1 THEN 'SOLICITADA'
WHEN a.STATUS = 2 THEN 'PROGRAMADA'
WHEN a.STATUS = 3 THEN 'ANDAMENTO'
WHEN a.STATUS = 4 THEN 'ENCERRADA'
END, vw_recursos.nome_maquina, '', a.tempo_gasto, horas_reparo_por_om.tempo,  vw_recursos.captotmes, f_month(a.data_solicitacao)||'-'||f_year(a.data_solicitacao),
vw_recursos.setor, vw_recursos.nome_setor, f_year(a.data_solicitacao), f_month(a.data_solicitacao),
f_month(a.data_solicitacao)||'-'||f_year(a.data_solicitacao)||a.recurso ,
b.n_cont,

case when b.data_solicitacao is not null then
b.data_solicitacao
else
a.data_solicitacao 
END,

vw_recursos.NOME_GRUPO ,

CASE
WHEN a.TIPO_MANUT = 1 THEN '-'
WHEN a.TIPO_MANUT = 2 THEN '-'
WHEN a.TIPO_MANUT = 3 THEN '-'
WHEN a.TIPO_MANUT = 4 THEN 'LEVE'
WHEN a.TIPO_MANUT = 5 THEN 'M�DIA'
WHEN a.TIPO_MANUT = 6 THEN 'CR�TICA'
END,

CASE
when A.tipo_manut = 1 THEN 'CORRETIVA'
when A.tipo_manut = 2 THEN 'PREVENTIVA'
when A.tipo_manut = 3 THEN 'PREDITIVA'
else 'OUTROS'
end



from tb_om a
left join vw_recursos on (a.recurso = vw_recursos.maquina and extract(year from a.data_solicitacao) = extract(year from vw_recursos.posicao) and  extract(month from a.data_solicitacao) = extract(month from vw_recursos.posicao))
left join horas_reparo_por_om on (a.om = horas_reparo_por_om.om)
left join tb_om b on (a.os_vinculada = b.n_cont)

 where a.data_solicitacao >='01.01.2018'
order by a.om
;



/* View: VW_OM_ANDAMENTO */
CREATE VIEW VW_OM_ANDAMENTO(
    ID_OM,
    ID_HORA,
    REGISTRO,
    INICIO,
    DATA)
AS
SELECT
A.id_om,
MIN(A.id_hora) as ID_HORA,
A.registro,
MIN(A.inicio) AS INICIO,
MIN(A.data) AS DATA
FROM tb_om_horas A
GROUP BY
A.id_om,
A.registro
;



/* View: VW_PADRAO */
CREATE VIEW VW_PADRAO(
    IDNUMPED,
    CODPROD,
    VLUNIT,
    STATUS)
AS
select idnumped, codprod, vlunit, status from tbpropitem
group by idnumped, codprod, vlunit, status order by codprod, idnumped
;



/* View: VW_PERMISSOES_USUARIO */
CREATE VIEW VW_PERMISSOES_USUARIO(
    ID_USER,
    ID_PERMISSAO,
    ID_COD)
AS
select a.userid, b.id_permissao, b.id_cod
from tb_user a
left join tb_perm_user b on (a.userid = b.id_usuario)
where b.id_permissao is null
;



/* View: VW_PPM */
CREATE VIEW VW_PPM(
    DATA,
    OPERADOR,
    TURNO,
    ORDEM,
    OPERACAO,
    MAQUINA,
    PRODUZIDO,
    REFUGO,
    CODIGO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    MES,
    ANO)
AS
select data, operador, turno, ordem, operacao, maquina, produzido, refugo, codigo, nome_maquina, setor, nome_setor, mes, ano
from producao_pecas union all
select data, operador, turno, ordem, operacao, maquina, produzido, refugo, codigo, nome_maquina, setor, nome_setor, mes, ano
from producao_perdas
;



/* View: VW_PPM_TOTAL */
CREATE VIEW VW_PPM_TOTAL(
    ORDEM,
    OPERACAO,
    MAQUINA,
    PRODUZIDO,
    REFUGO,
    CODIGO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    MES,
    ANO)
AS
select ordem, operacao, maquina, SUM(produzido), SUM(refugo),
codigo, nome_maquina, setor, nome_setor , mes, ano
from vw_ppm GROUP by
ordem, operacao, maquina,
codigo, nome_maquina, setor, nome_setor, mes, ano
;



/* View: VW_PRODUCAO_LIQ */
CREATE VIEW VW_PRODUCAO_LIQ(
    DT_MOVTO,
    MAQUINA,
    TURNO,
    HS_DISP,
    ORDEM,
    CODIGO,
    OPERACAO,
    OPERADOR,
    QTDE,
    TEMPO_PARADO,
    TEMPO_LIQ,
    PROD_LIQ,
    CICLO_ROTEIRO,
    CICLO_MAQ,
    CC_ROTEIRO,
    ANO,
    MES,
    CC,
    NOME_MAQUINA,
    NOME_TIPO_MAQUINA,
    NOME_SETOR,
    TIPO_MAQUINA,
    SETOR)
AS
select a.dt_movto,
a.maquina,
a.turno,
a.hs_disp,
b.ordem,
b.codigo,
b.operacao,
b.operador,
coalesce(b.qtde, 0) as qtde,

case
when coalesce(c.tempo,0) >= coalesce(a.hs_disp,0)
then coalesce(a.hs_disp,0)-1
else
coalesce(c.tempo,0)
end
as tempo_parado,


case when
coalesce(a.hs_disp,0) - coalesce(c.tempo,0) < 0
then 0
else
a.hs_disp - coalesce(c.tempo,0)-1
end
as tempo_liq,

cast(
case when
    (case when
        a.hs_disp - coalesce(c.tempo,0) < 0
        then 0
        else
        a.hs_disp - coalesce(c.tempo,0)-1
    end) = 0 and b.qtde = 0 then 0
    else

      case when (b.ciclo_roteiro > 0) or (b.ciclo_maq > 0)
      then
        (case when
            /*Se o Tempo l�quido for menor que zero ignora o apontamento*/
            a.hs_disp - coalesce(c.tempo,0) < 0
            then 0
            else
                /* Se o apontamento lan�ou qtde com hora parada, ignora a parada e apura qtde */
                case when (a.hs_disp - coalesce(c.tempo,0)=0 and b.qtde > 0) then
                a.hs_disp - 1
                else
                a.hs_disp - coalesce(c.tempo,0)-1
                end
          end) * 3600 / (case when
            b.ciclo_maq > 0 then b.ciclo_maq
            else
            b.ciclo_roteiro
            end)
       else 0
       end
end as int) as prod_liq,

b.ciclo_roteiro,
b.ciclo_maq,
b.cc_roteiro,
a.ano,
a.mes, 
a.cc,
a.nome_maquina,
a.nome_tipo_maquina,
a.nome_setor,
a.tipo_maquina,
a.setor
from vw_apontados a
left join vw_apontados_qtd b
on (a.dt_movto = b.dt_movto and a.maquina = b.maquina and a.turno = b.turno)
left join vw_apontados_paradas c
on (a.dt_movto = c.dt_movto and a.maquina = c.maquina and a.turno = c.turno)
;



/* View: VW_PRODUTIVIDADE */
CREATE VIEW VW_PRODUTIVIDADE(
    TURNO,
    OPERACAO,
    MAQUINA,
    QUANTIDADE,
    CODIGO,
    NOME_MAQUINA,
    SETOR,
    NOME_SETOR,
    TEMPO_GASTO,
    CICLO_ORCADO,
    TEMPO_ORCADO,
    MES,
    ANO)
AS
select a.turno, a.operacao,
a.maquina, sum(a.quantidade), a.codigo,
 c.nome_maquina, c.setor, c.nome_setor,
SUM(a.tempo), b.seg_peca , coalesce(b.seg_peca*sum(a.quantidade)/3600,0)
, f_month(a.data), f_year(a.data)

from tb_apontamento a
left join
vw_tb_roteiro_simples b on (a.codigo = b.codigo and a.operacao = b.seq)
left join setores c on (a.maquina = c.maquina)
where a.lancamento = 1
group by a.turno, a.operacao,
a.maquina,  a.inicio, a.fim, a.codigo,
 c.nome_maquina, c.setor, c.nome_setor, b.seg_peca,
 f_month(a.data), f_year(a.data)
;



/* View: VW_TBARVORE */
CREATE VIEW VW_TBARVORE(
    ARVORE,
    DESCARVORE,
    PRODUTO,
    DATAINC,
    CLIENTE,
    LOTE,
    VRARVMAT,
    VRARVTRAT,
    VRARVOPER,
    VRARVTOT,
    CODCLI,
    COD_DESENHO,
    COD_FATURAM,
    OBSERVACOES,
    LOTE_ANUAL,
    ORIGEM,
    SDO,
    CAMINHO_DESENHO,
    STATUS_ORCAMENTO)
AS
select arvore, descarvore, produto, datainc, cliente, lote, vrarvmat, vrarvtrat,
vrarvoper, vrarvtot, codcli, cod_desenho, cod_faturam, observacoes, lote_anual, origem,
sdo,  caminho_desenho,
case
when sdo = '0' then 'PENDENTE'
when sdo = '1' then 'OR�ADO'
when sdo = '2' then 'REVISAO'
ELSE 'PENDENTE'
END
from tbarvore
;



/* View: VW_TBARVOREMAT */
CREATE VIEW VW_TBARVOREMAT(
    IDARVMAT,
    ARVORE,
    PRODUTO,
    TIPOMP,
    CODIGOITEM,
    COMP,
    LARG,
    COMPRIMAT,
    LARGMAT,
    ESPMAT,
    QTDEMAT,
    PCSCAIXA,
    CONSUMO,
    COMPONENTE,
    SEQ,
    CALCULO,
    APR,
    UNDINF,
    OBS,
    DESCRICAOITEM,
    REVPRECO,
    PRECOPOR,
    VRCOMPRA,
    USUARIO,
    ALTERACAO,
    ULTIMOCAMPO,
    PESOBLANK,
    PCSCH,
    VRTRAT,
    VRMAT,
    VRMO,
    VRITEM,
    ORIGEM,
    DESTINO,
    MNUM,
    AREA,
    NIVEL,
    ROTEIRO,
    PERDAKG,
    PERDAPORC,
    CUSTOMAT,
    VROPER,
    VRSERV,
    VRTOT,
    VRUNIT,
    PESO_LIQ,
    KIT,
    PCS_KIT,
    TEMPO_MONTAGEM,
    TEMPO_CONSUMO,
    CALC_CAVACO)
AS
select idarvmat, tbarvoremat.arvore, produto, tipomp, tbarvoremat.codigoitem, tbarvoremat.comp,
tbarvoremat.larg, tbarvoremat.comprimat, tbarvoremat.largmat, tbarvoremat.espmat, qtdemat, pcscaixa,
consumo, componente, tbarvoremat.seq, tbarvoremat.calculo, apr, undinf, obs,
descricaoitem, revpreco, precopor, vrcompra, usuario,
alteracao, ultimocampo, pesoblank, pcsch, vrtrat, vrmat,
vrmo, vritem, origem, destino, mnum, area, nivel, roteiro,
perdakg, perdaporc, customat, vroper, vrserv, vrtot, vrunit,
peso_liq, kit, pcs_kit, tempo_montagem, tempo_consumo, coalesce(tbitens.camminimaitem,0)
from tbarvoremat left join tbitens on (tbarvoremat.codigoitem = tbitens.codigoitem)
;



/* View: VW_TOTAIS_MANUTENCAO_SETOR */
CREATE VIEW VW_TOTAIS_MANUTENCAO_SETOR(
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    RECURSO,
    QTD_OM,
    QTD_HORAS,
    QTD_TRAB,
    DISP_MES,
    TIPO_MANUT,
    NATUREZA_MANUT,
    ANO_SOLIC,
    MES_OM,
    REF_MAQ)
AS
select b.mes_solic, a.grupo, a.nome_grupo, a.maquina,





count(b.n_cont) as qtd_om,

sum(b.tempo_gasto) as parada,

sum(b.tempo_reparo) as trabalhado,

a.captotmes, b.natureza_manut, b.tipo_manut, a.ano_solic, a.mes_om, a.ref_maq
from vw_setores a LEFT join vw_horas_manutencao b on (a.maquina = b.recurso and a.mes_om = b.mes_om
and a.ano_solic = b.ano_solic)
where b.natureza_manut = 1 and b.tipo_manut = 1
group by b.mes_solic, a.grupo, a.nome_grupo, a.maquina,
a.captotmes, b.natureza_manut, b.tipo_manut, a.ano_solic, a.mes_om, a.ref_maq
order by a.grupo, a.maquina, a.ano_solic, a.mes_om
;



/* View: VW_TOTAIS_SETORES */
CREATE VIEW VW_TOTAIS_SETORES(
    MES_SOLIC,
    SETOR,
    NOME_SETOR,
    RECURSO,
    DISP_MES,
    ANO_SOLIC,
    MES_OM,
    REF_MAQ)
AS
select a.mes_ano, a.grupo, a.nome_grupo, a.maquina,
a.captotmes, a.ano_solic, a.mes_om, a.ref_maq
from vw_setores a
group by a.mes_ano, a.grupo, a.nome_grupo, a.maquina,
a.captotmes, a.ano_solic, a.mes_om, a.ref_maq
order by a.grupo, a.maquina, a.ano_solic, a.mes_om
;



/* View: WHERE_USED */
CREATE VIEW WHERE_USED(
    CODIGO,
    NOME,
    APLICACAO,
    NOME_APLICACAO,
    QTD,
    UND,
    ESTRUTURA)
AS
SELECT B.codigoitem,
   CASE
   WHEN f_stringlength(B.refitem) > 1 THEN B.nomeitem || ' ('|| B.refitem ||')'
   ELSE  B.nomeitem
   END, C.produto,

   CASE
   WHEN f_stringlength(D.refitem) > 1 THEN D.nomeitem || ' ('|| D.refitem ||')'
   ELSE  D.nomeitem
   END,
   C.consumo, C.undinf, C.arvore
   FROM tbitens B LEFT JOIN (tbarvoremat C LEFT JOIN TBITENS D ON C.produto = D.codigoitem)
       ON B.codigoitem = C.codigoitem
;


