#include "Rwmake.ch"
#include "Protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "totvs.ch"

/*
//------------------------
Autor: João Henrique Dib
Projeto: Tarefa de criação de rotina para trabalhar com a tabela SA2
04/06/2024
//------------------------
*/

User Function tarefaF()

	Local oButton1
	Local oButton2
	Local oButton3
	Local oButton4
	Local oButton5
	Local oMsDialog
	Local oFont := TFont():New('Arial',,24,.T.)
	Local _aSize := MsAdvSize()
	Private num := 0
	Private oFont2 := TFont():New('Arial',,13,.T.)
	Private aCord := {0,0,0,0}
	Private oBrowse

	//RpcSetType(3)
	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT"

	aCord[1] := 5
	aCord[2] := 5
	aCord[3] := 320
	aCord[4] := 575

	_aSize[5] := 1522
	_aSize[6] := 684
	oFont:Bold := .T.

	oMsDialog := TDialog():New(0, 0, _aSize [6]-30, _aSize [5]-200,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)



	/////////////////////// CRIANDO VISÃO DO BANCO ///////////////////////
	dbSelectArea("SA2")

	oBrowse := MsSelBr():New( 5,5,570,315,,,,oMsDialog,,,,,,,,,,,,.F.,'SA2',.T.,,.F.,,, )

	oBrowse:AddColumn(TCColumn():New('Codigo',{||SA2->A2_COD },,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Loja'  ,{||SA2->A2_LOJA},,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Nome'  ,{||SA2->A2_NOME},,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('CPF/CNPJ'  ,{||SA2->A2_CGC},,,,'LEFT',,.F.,.F.,,,,.F.,))

	oBrowse:lHasMark := .T.
	//oBrowse:bAllMark := {|| alert('Click no header da browse') }

	/////////////////////// BOTÕES ///////////////////////
	oButton1 := TButton():Create(oMsDialog,15,581,"Inserir",{||insert()},75,20,,,,.T.,,,,,,)

	oButton2 := TButton():Create(oMsDialog,45,581,"Editar",{||update()},75,20,,,,.T.,,,,,,)

	oButton3 := TButton():Create(oMsDialog,75,581,"Deletar",{||delete()},75,20,,,,.T.,,,,,,)

	oButton4 := TButton():Create(oMsDialog,105,581,"Visualizar",{||view()},75,20,,,,.T.,,,,,,)

	oButton5 := TButton():Create(oMsDialog,135,581,"Gerar relatório completo",{||PRINTCOMPLETEGRAPH()},75,20,,,,.T.,,,,,,)

	oButton6 := TButton():Create(oMsDialog,165,581,"Gerar relatório resumido",{||PRINTGRAPH()},75,20,,,,.T.,,,,,,)

	oButton6 := TButton():Create(oMsDialog,195,581,"Fechar",{||oMsDialog:end()},75,20,,,,.T.,,,,,,)

	/////////////////////// ATIVANDO JANELA ///////////////////////
	oMsDialog:Activate(,,,.T.,,,)




	//RESET ENVIRONMENT
RETURN


Static Function insert()
	Local oJanela  := TDialog():New(0, 0, 730, 1100, 'Cadastro de fornecedores', , , , , CLR_BLACK, CLR_WHITE, , , .T.)
	Local nNumero := 0

	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }
	Local aEstados := FWGetSX5("12")
	Local aPaises := trataPaises()
	Local aEstados2 := {}
	Local aIdent := getIdent()
	Local aSimNao := { "2 - Não", "1 - Sim" }
	Local aNaoSim := { "1 - Sim", "2 - Não" }
	Local aClasPj := {"1 - Imune", "2 - Isento"}
	Local aConf := {"0 - Parâmetro","1 - Pré-Nota","2 - Nota Fiscal","3 - Não utiliza"}
	Local aIdentPr := { "1 - Pedido Compra", "2 - Recebimento", "3 - Nao Imprime", "4 - Documento Entrada" }
	Local oPVinculo := getOpVinculo()
	Local aCalcsIRFF := { "1 - Normal", "2 - IRFF Baixa", "3 - Simples", "4 - Empresa Individual" }
	Local aInovaut := { "1 - Participa", "2 - Não Participa", "3 - Convidar" }
	Local aIndRural := {"1 - Sobre a comercializacao da sua producao","2 - Sobre a folha de pagamento"}
	Local aTipos := { "F - Físico", "J - Jurídico" }
	Local aContr := { "J - Jurídico", "F - Pessoa Fisica", "L - Familiar" }
	Local aClientes := getClientes()
	Local aCodLoc := getCodLoc()
	Local aMotNif := {"1 - Dispensado do NIF", "2 - País não exige NIF"}
	Local aProdRur := { "0 - Não é prod.rural", "1 - Seg.Espec.Geral PF", "2 - Seg.Espec.Ent.PAA PF", "3 - Ent.PAA PJ" }
	Local aPisCof := { '1 - Legado', '2 - ICMS e IPI', '3 - ICMS', '4 - IPI', '5 - Nenhum', '6 - Soma IPI' }
	Local aValores := { ;
		{'', 'Código'}, ;
		{'', 'Loja'}, ;
		{'', 'Razão Social'}, ;
		{'', 'Estado'}, ;
		{'', 'Municipio'}, ;
		{'', 'Endereço'}, ;
		{'', 'Nome Fantasia'}, ;
		{'', 'Tipo'} ;
		}

	Local aSitEspRes := { '1 - Ex Pr bde Ser', '2 - Pr de Ser c/ Ded', '3 - Con Civ', '4 - Ag de Tu/Adm Fun', '5 - Pro e Pub/Int', '6 - Pro e Pub/Int Is', '7 - Não In/Re/Rep' }
	Local aTpj := { '1 - ME - Micro Empresa', '2 - EPP - Empresas de Pequeno Porte', '3 - MEI - Microempreendedor Individual', '4 - Cooperativa', '5 - Não optante' }
	Local aCivil := { "1 - Solteiro", "2 - Casado", "3 - Divorciado", "4 - Viuvo", "5 - Companheiro(a)", "x - Anonimizado", "" }
	Local aValoresN := { ;
		{'', 'CPF/CNPJ'}, ;
		{'', 'Código Município'}, ;
		{'', 'Telefone'}, ;
		{'', 'RG/Ced.Estr.'}, ;
		{'', 'Ins. Estad.'}, ;
		{'', 'Ins. Municip.'}, ;
		{'', 'DDI'}, ;
		{'', 'País'}, ;
		{'', 'DDD'}, ;
		{'', 'Descr. País'}, ;
		{'', 'Departamento'}, ;
		{'', 'Email'}, ;
		{'', 'Homepage'}, ;
		{'', 'TELEX'}, ;
		{'', 'END. COMPLEMENTAR'}, ;
		{'', 'Bloqueado'}, ;
		{'', 'Complemento'}, ;
		{'', 'Forn.Mailing'}, ;
		{'', 'Cod CBO'}, ;
		{'', 'Cod CNAE'}, ;
		{'', 'Banco'}, ;
		{'', 'Cod. Agência'}, ;
		{'', 'Cta Corrente'}, ;
		{'', 'Natureza'}, ;
		{'', 'Cond. Pagto'}, ;
		{'', 'CodAdm'}, ;
		{'', 'Forma de pagamento'}, ;
		{'', 'Dv Cta Cnab'}, ;
		{'', 'DV Ag Cnab'}, ;
		{'', 'Tp.Contr.Soc'}, ;
		{'', 'Recolhe ISS'}, ;
		{'', 'Cod. Mun. ZF'}, ;
		{'', 'Calc. INSS'}, ;
		{'', 'Tipo Pessoa'}, ;
		{'', 'País Bacen'}, ;
		{'', 'Tipo Escr.'}, ;
		{'', 'Grp. Tribut.'}, ;
		{'', 'Rec. PIS'}, ;
		{'', 'Rec.CSLL'}, ;
		{'', 'Rec.COFINS'}, ;
		{'', 'Cálc. IRRF'}, ;
		{'', 'P. Vinculo'}, ;
		{Date(), 'Dt Ini Vincu'}, ;
		{Date(), 'Dt Fim Vincu'}, ;
		{'', 'Rec. FACS'}, ;
		{'', 'Contribuinte'}, ;
		{'', 'Rec. FABOV'}, ;
		{'', 'Ded. PIS/COF'}, ;
		{'', 'Rec. Famad'}, ;
		{'', 'Reg. CPOM'}, ;
		{'', 'SitEspRes BH'}, ;
		{'', 'Tp. Lograd'}, ;
		{'', 'TPJ'}, ;
		{Date(), 'Dt. Conv'}, ;
		{'', 'Contr TARE?'}, ;
		{'', 'Rec. FETHAB'}, ;
		{'', 'Vlr. Min. IR'}, ;
		{'', 'Inc.Prd.Leit'}, ;
		{'', 'Fome Zero'}, ;
		{'', 'IRRF Prog'}, ;
		{'', 'Inovar Auto'}, ;
		{'', 'Nome Resp.'}, ;
		{'', 'Contato'}, ;
		{'', 'Transp.'}, ;
		{'', '1a Compra'}, ;
		{'', 'Ult Compra'}, ;
		{'', 'Estado Civil'}, ;
		{'', 'Recolhe SEST'},  ;
		{'', 'SubDivPais'},  ;
		{'', 'Tipo Contrat'},  ;
		{'', 'Codigo NIF'},  ;
		{Date(), 'Data Fim'},  ;
		{Date(), 'Data Inicio'},  ;
		{'', 'Benef. Rend.'},  ;
		{'', 'Est./Prov.'},  ;
		{'', 'Forma Trib'},  ;
		{'', 'Logradouro'},  ;
		{'', 'Complemento'},  ;
		{'', 'Bairro/Dist.'},  ;
		{'', 'Rendimento'},  ;
		{'', 'Cidade'},  ;
		{'', 'CNPJ Empr.Ex'},  ;
		{'', 'Num Insc Aut'},  ;
		{Date(), 'Data nasc.'},  ;
		{'', 'Categ. SEFIP'},  ;
		{'', 'Ocorrência'},  ;
		{'', 'Cat eSocial'},  ;
		{'', 'Prioridade'},  ;
		{'', 'Identificac.'},  ;
		{'', 'Represent.'}, ;
		{'', 'Identif.Repr.'}, ;
		{'', 'Fabricante'}, ;
		{'', 'Cod.Local'},  ;
		{'', 'Maior Nota'},  ;
		{'', 'Rec Cide'},  ;
		{'', 'Cod.Bloqueio'},  ;
		{'','Ind. Prod. Rur'}, ;
		{'','UF Ficticia'}, ;
		{'','LC ISS RS'}, ;
		{'','Rec.FASE-MT'}, ;
		{'','CCICMS'}, ;
		{'','Rec. IMA-MT'}, ;
		{'','Cod. FIESP'}, ;
		{'','Rg. Simp. MT'}, ;
		{'','Ret. CPRB'}, ;
		{'', 'Ind. Rural'}, ;
		{'', 'Ident.Exp.'}, ;
		{'', 'Inc. Cultura'}, ;
		{'', 'Assoc. Desp.'}, ;
		{'', 'Calc.INSS.Pt'}, ;
		{'', 'Ident.Prod.'}, ;
		{'', 'Cód. Cliente'}, ;
		{'', 'Opt Simp Nac'}, ;
		{'', 'Cód Func'}, ;
		{'','Rec.FUNDESA'}, ;
		{'','Ind. Prest.'}, ;
		{'','M.Jurídico'}, ;
		{'','Cod Mun SC'},;
		{'','CPF Rural'}, ;
		{'','Pes.Tri.Fav'}, ;
		{'','Fil. Transf.'}, ;
		{Date(),'BlqTemporal'}, ;
		{'','Cod.Mun.SIAF'}, ;
		{'','End.Not.Form'}, ;
		{'', 'Mot.NIF'},;
		{'', 'Loja Cliente'},;
		{'', 'Clas.PJ'},;
		{'', 'Cargo Resp.'},;
		{'', 'Conf. Física'};
		}

	Local aMunicipios := {}
	Local aNaturezas := getNatCondAdm("SED")
	Local aCondominios := getNatCondAdm("SE4")
	Local aCodAdms := getNkatCondAdm("SAE")
	Local aPagtos := getPagtos()
	Local aTipoPessoa := { "CI - Comercio/Industria", "PF - Pessoa Fisica", "OS - Prestacao de Servico" }
	Local aZF := getZF()
	Local OPFisica
	Local nNumero

	Local oTFolder := TFolder():New(0, 0, aTFolder, , oJanela, , , , .T., , 551, 730)



	/////////////////////// ABAS ///////////////////////
	Local oTFolder := TFolder():New( 0,0,aTFolder,,oJanela,,,,.T.,,551,730 )


	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next


	/////////////////////// ABA 'Cadastrais' ///////////////////////

	oCodigo       := TGet():New( 000, 001, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oCGC		  := TGet():New( 000, 100, {|u|if(PCount()==0,aValoresN[1][1],aValoresN[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 999.999.999-99",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[1][1],,,,,,,aValoresN[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 020, 001, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oCodMun		  := TComboBox():New( 020, 100, {|u|if(PCount()>0,aValoresN[2][1]:=u,aValoresN[2][1])}, aMunicipios, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[2][1], aValoresN[2][2], 1, , )

	oNFantasia    := TGet():New( 040, 001, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oTelefone     := TGet():New( 040, 100, {|u|if(PCount()==0,aValoresN[3][1],aValoresN[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 9999-9999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[3][1],,,,,,,aValoresN[3][2],1,,,,.T.,)

	oEstado       := TComboBox():New( 060, 001, {|u|if(PCount()>0,aValores[4][1]:=u,aValores[4][1])}, aEstados2, 100, , oTFolder:aDialogs[1], , {||getComboMunicipios(oEstado, @oCodMun)}, , , , .T., ,, , , , , , , aValores[4][1], aValores[4][2], 1, , )
	getComboMunicipios(oEstado, @oCodMun)

	OPFisica 	  := TGet():New( 060, 100, {|u|if(PCount()==0,aValoresN[4][1],aValoresN[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[4][1],,,,,,,aValoresN[4][2],1,,,,.T.,)

	oMunicipio    := TGet():New( 085, 001, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oInscr 		  := TGet():New( 085, 100, {|u|if(PCount()==0,aValoresN[5][1],aValoresN[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 99999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[5][1],,,,,,,aValoresN[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 001, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oInscrM 	  := TGet():New( 105, 100, {|u|if(PCount()==0,aValoresN[6][1],aValoresN[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[6][1],,,,,,,aValoresN[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 001, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)

	oDdi          := TGet():New( 125, 100, {|u|if(PCount()==0,aValoresN[8][1],aValoresN[8][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[8][1],,,,,,,aValoresN[8][2],1,,,,.T.,)

	oDdd          := TGet():New( 150, 100, {|u|if(PCount()==0,aValoresN[9][1],aValoresN[9][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[9][1],,,,,,,aValoresN[9][2],1,,,,.T.,)

	oPais 		  := TComboBox():New( 180, 001, {|u|if(PCount()>0,aValoresN[8][1]:=u,aValoresN[8][1])}, aPaises, 200, , oTFolder:aDialogs[1], ,{|| trocaDescPais(aValoresN[8][1], @oDescPais)}, , , , .T., ,, , , , , , , aValoresN[8][1], aValoresN[8][2], 1, , )

	oDescPais	  := TGet():New( 200, 100, {|u|if(PCount()==0,aValoresN[10][1],aValoresN[10][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[10][1],,,,,,,aValoresN[10][2],1,,,,.T.,)

	oDept 		  := TGet():New( 000, 200, {|u| if(PCount()==0, aValoresN[11][1], aValoresN[11][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[11][1],,,,,,, aValoresN[11][2],1,,,,.T.,)

	oEmail 		  := TGet():New( 020, 200, {|u| if(PCount()==0, aValoresN[12][1], aValoresN[12][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[12][1],,,,,,, aValoresN[12][2],1,,,,.T.,)

	oHpage 		  := TGet():New( 040, 200, {|u| if(PCount()==0, aValoresN[13][1], aValoresN[13][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[13][1],,,,,,, aValoresN[13][2],1,,,,.T.,)

	oTelex 		  := TGet():New( 060, 200, {|u| if(PCount()==0, aValoresN[14][1], aValoresN[14][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[14][1],,,,,,, aValoresN[14][2],1,,,,.T.,)

	oEndcomp 	  := TGet():New( 080, 200, {|u| if(PCount()==0, aValoresN[15][1], aValoresN[15][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[15][1],,,,,,, aValoresN[15][2],1,,,,.T.,)

	oBloq         := TComboBox():New( 100, 200, {|u|if(PCount()>0,aValoresN[16][1]:=u,aValoresN[16][1])}, aSimNao, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[16][1], aValoresN[16][2], 1, , )

	oComplem      := TGet():New( 120, 200, {|u| if(PCount()==0, aValoresN[17][1], aValoresN[17][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[17][1],,,,,,, aValoresN[17][2],1,,,,.T.,)

	oForm         := TComboBox():New( 140, 200, {|u|if(PCount()>0,aValoresN[18][1]:=u,aValoresN[18][1])}, aSimNao, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[18][1], aValoresN[18][2], 1, , )

	oCbo		  := TGet():New( 160, 200, {|u| if(PCount()==0, aValoresN[19][1], aValoresN[19][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[19][1],,,,,,, aValoresN[19][2],1,,,,.T.,)

	oCnae 		  := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[20][1], aValoresN[20][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999-9/9999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[20][1],,,,,,, aValoresN[20][2],1,,,,.T.,)


	/////////////////////// ABA 'Adm/Fin.' ///////////////////////

	oBanco		  := TGet():New( 000, 001, {|u|if(PCount()==0,aValoresN[21][1],aValoresN[21][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[21][1],,,,,,,aValoresN[21][2],1,,,,.T.,)

	oCodAgencia	  := TGet():New( 020, 001, {|u|if(PCount()==0,aValoresN[22][1],aValoresN[22][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[22][1],,,,,,,aValoresN[22][2],1,,,,.T.,)

	oCtCorrente	  := TGet():New( 040, 001, {|u|if(PCount()==0,aValoresN[23][1],aValoresN[23][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[23][1],,,,,,,aValoresN[23][2],1,,,,.T.,)

	oNatureza     := TComboBox():New( 060, 001, {|u|if(PCount()>0,aValoresN[24][1]:=u,aValoresN[24][1])}, aNaturezas, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[24][1], aValoresN[24][2], 1, , )

	oCondominio   := TComboBox():New( 080, 001, {|u|if(PCount()>0,aValoresN[25][1]:=u,aValoresN[25][1])}, aCondominios, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[25][1], aValoresN[25][2], 1, , )

	oCodAdm		  := TComboBox():New( 100, 001, {|u|if(PCount()>0,aValoresN[26][1]:=u,aValoresN[26][1])}, aCodAdms, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[26][1], aValoresN[26][2], 1, , )

	oFormPagto	  := TComboBox():New( 120, 001, {|u|if(PCount()>0,aValoresN[27][1]:=u,aValoresN[27][1])}, aPagtos, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[27][1], aValoresN[27][2], 1, , )

	oDvcta        := TGet():New( 140, 001, {|u| if(PCount()==0, aValoresN[28][1], aValoresN[28][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@N 99", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[28][1],,,,,,, aValoresN[28][2],1,,,,.T.,)

	oDvAg         := TGet():New( 160, 001, {|u| if(PCount()==0, aValoresN[29][1], aValoresN[29][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E X", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[29][1],,,,,,, aValoresN[29][2],1,,,,.T.,)

	/////////////////////// ABA 'Fiscais' ///////////////////////

	oTipoContr := TComboBox():New( 000, 001, {|u|if(PCount()>0,aValoresN[30][1]:=u,aValoresN[30][1])}, aContr, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[30][1], aValoresN[30][2], 1, , )

	oRecIss    := TComboBox():New( 030, 001, {|u|if(PCount()>0,aValoresN[31][1]:=u,aValoresN[31][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[31][1], aValoresN[31][2], 1, , )

	oCodMunZf  := TComboBox():New( 060, 001, {|u|if(PCount()>0,aValoresN[32][1]:=u,aValoresN[32][1])}, aZF, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[32][1], aValoresN[32][2], 1, , )

	oCalcInss  := TComboBox():New( 090, 001, {|u|if(PCount()>0,aValoresN[33][1]:=u,aValoresN[33][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[33][1], aValoresN[33][2], 1, , )

	oTPessoa   := TComboBox():New( 120, 001, {|u|if(PCount()>0,aValoresN[34][1]:=u,aValoresN[34][1])}, aTipoPessoa, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[34][1], aValoresN[34][2], 1, , )

	oPaisBacen := TComboBox():New( 150, 001, {|u|if(PCount()>0,aValoresN[35][1]:=u,aValoresN[35][1])}, aPaises, 150, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[35][1], aValoresN[35][2], 1, , )

	oTipoEscr  := TGet():New( 180, 001, {|u| if(PCount()==0, aValoresN[36][1], aValoresN[36][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@N 99",{|| verificaTipoEscr(@oTipoEscr)} ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[36][1],,,,,,, aValoresN[36][2],1,,,,.T.,)

	oGrpTrib   := TGet():New( 210, 001, {|u| if(PCount()==0, aValoresN[37][1], aValoresN[37][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[37][1],,,,,,, aValoresN[37][2],1,,,,.T.,)

	oRecPis    := TComboBox():New( 240, 001, {|u|if(PCount()>0,aValoresN[38][1]:=u,aValoresN[38][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[38][1], aValoresN[38][2], 1, , )

	oRecCSLL   := TComboBox():New( 270, 001, {|u|if(PCount()>0,aValoresN[39][1]:=u,aValoresN[39][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[39][1], aValoresN[39][2], 1, , )

	oRecCofins := TComboBox():New( 300, 001, {|u|if(PCount()>0,aValoresN[40][1]:=u,aValoresN[40][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[40][1], aValoresN[40][2], 1, , )

	oCalcIRRF  := TComboBox():New( 000, 100, {|u|if(PCount()>0,aValoresN[41][1]:=u,aValoresN[41][1])}, aCalcsIRFF, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[41][1], aValoresN[41][2], 1, , )

	oPVinculo  := TComboBox():New( 030, 100, {|u|if(PCount()>0,aValoresN[42][1]:=u,aValoresN[42][1])}, getOpVinculo(), 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[42][1], aValoresN[42][2], 1, , )

	oDtIniV    := TGet():New( 060, 100, {|u| if(PCount()==0, aValoresN[43][1], aValoresN[43][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[43][2],1,,,,.T.,)

	oDtFimV    := TGet():New( 090, 100, {|u| if(PCount()==0, aValoresN[44][1], aValoresN[44][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[44][2],1,,,,.T.,)

	oRecFacs   := TComboBox():New( 120, 100, {|u|if(PCount()>0,aValoresN[45][1]:=u,aValoresN[45][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[45][1], aValoresN[45][2], 1, , )

	oContrib   := TComboBox():New( 150, 100, {|u|if(PCount()>0,aValoresN[46][1]:=u,aValoresN[46][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[46][1], aValoresN[46][2], 1, , )

	oRecFabov  := TComboBox():New( 180, 100, {|u|if(PCount()>0,aValoresN[47][1]:=u,aValoresN[47][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[47][1], aValoresN[47][2], 1, , )

	oDedPis    := TComboBox():New( 210, 100, {|u|if(PCount()>0,aValoresN[48][1]:=u,aValoresN[48][1])}, aPisCof, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[48][1], aValoresN[48][2], 1, , )

	oRecFmd    := TComboBox():New( 240, 100, {|u|if(PCount()>0,aValoresN[49][1]:=u,aValoresN[49][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[49][1], aValoresN[49][2], 1, , )

	oRecCpom   := TComboBox():New( 270, 100, {|u|if(PCount()>0,aValoresN[50][1]:=u,aValoresN[50][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[50][1], aValoresN[50][2], 1, , )

	oSitEspRes := TComboBox():New( 300, 100, {|u|if(PCount()>0,aValoresN[51][1]:=u,aValoresN[51][1])}, aSitEspRes, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[51][1], aValoresN[51][2], 1, , )

	oTpLograd  := TGet():New( 000, 200, {|u| if(PCount()==0, aValoresN[52][1], aValoresN[52][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[52][1],,,,,,, aValoresN[52][2],1,,,,.T.,)

	oTpj       := TComboBox():New( 030, 200, {|u|if(PCount()>0,aValoresN[53][1]:=u,aValoresN[53][1])}, aTpj, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[53][1], aValoresN[53][2], 1, , )

	oDtConv    := TGet():New( 060, 200, {|u| if(PCount()==0, aValoresN[54][1], aValoresN[54][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[54][2],1,,,,.T.,)

	oCTare     := TComboBox():New( 090, 200, {|u|if(PCount()>0,aValoresN[55][1]:=u,aValoresN[55][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[55][1], aValoresN[55][2], 1, , )

	oRecFet    := TComboBox():New( 120, 200, {|u|if(PCount()>0,aValoresN[56][1]:=u,aValoresN[56][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[56][1], aValoresN[56][2], 1, , )

	oVlrMinIr  := TComboBox():New( 150, 200, {|u|if(PCount()>0,aValoresN[57][1]:=u,aValoresN[57][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[57][1], aValoresN[57][2], 1, , )

	oIncPdrLei := TComboBox():New( 180, 200, {|u|if(PCount()>0,aValoresN[58][1]:=u,aValoresN[58][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[58][1], aValoresN[58][2], 1, , )

	oFomeZer   := TComboBox():New( 210, 200, {|u|if(PCount()>0,aValoresN[59][1]:=u,aValoresN[59][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[59][1], aValoresN[59][2], 1, , )

	oIRProg    := TComboBox():New( 240, 200, {|u|if(PCount()>0,aValoresN[60][1]:=u,aValoresN[60][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[60][1], aValoresN[60][2], 1, , )

	oInovaut   := TComboBox():New( 270, 200, {|u|if(PCount()>0,aValoresN[61][1]:=u,aValoresN[61][1])}, aInovaut, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[61][1], aValoresN[61][2], 1, , )

	oNomResp   := TGet():New( 300, 200, {|u| if(PCount()==0, aValoresN[62][1], aValoresN[62][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[62][2],1,,,,.T.,)

	/////////////////////// ABA 'Compras' ///////////////////////

	oContato   := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[63][1], aValoresN[63][1]:=u)}, oTFolder:aDialogs[4], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[63][2],1,,,,.T.,)

	oTransp    := TComboBox():New( 030, 001, {|u|if(PCount()>0,aValoresN[64][1]:=u,aValoresN[64][1])}, getTransportadora(), 100, , oTFolder:aDialogs[4], ,, , , , .T., ,, , , , , , , aValoresN[64][1], aValoresN[64][2], 1, , )

	/////////////////////// ABA 'Compras' ///////////////////////

	oCivil     := TComboBox():New( 000, 001, {|u|if(PCount()>0,aValoresN[67][1]:=u,aValoresN[67][1])}, aCivil, 100, , oTFolder:aDialogs[5], ,, , , , .T., ,, , , , , , , aValoresN[67][1], aValoresN[67][2], 1, , )


	/////////////////////// ABA 'TMS' ///////////////////////

	oSest      := TComboBox():New( 000, 001, {|u|if(PCount()>0,aValoresN[68][1]:=u,aValoresN[68][1])}, aNaoSim, 100, , oTFolder:aDialogs[6], ,, , , , .T., ,, , , , , , , aValoresN[68][1], aValoresN[68][2], 1, , )


	///////////////////////// ABA 'Residente Exterior' ///////////////////////

	oSubDiv  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[69][1], aValoresN[69][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@E XXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[69][2],1,,,,.T.,)

	oTipoCon := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[70][1], aValoresN[70][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[70][2],1,,,,.T.,)

	oCodNif  := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[71][1], aValoresN[71][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@N 99999999999999999999999999999999999999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[71][2],1,,,,.T.,)

	oDataFim := TGet():New( 090, 001, {|u| if(PCount()==0, aValoresN[72][1], aValoresN[72][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[72][2],1,,,,.T.,)

	oDataIni := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[73][1], aValoresN[73][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[73][2],1,,,,.T.,)

	///////////////////////// ABA 'Autônomos' ///////////////////////

	oSubDiv  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[83][1], aValoresN[83][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@N 9999.9999.999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[83][2],1,,,,.T.,)

	oDataN   := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[84][1], aValoresN[84][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[84][2],1,,,,.T.,)

	oSefip   := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[85][1], aValoresN[85][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[85][2],1,,,,.T.,)

	oOcorr   := TGet():New( 090, 001, {|u| if(PCount()==0, aValoresN[86][1], aValoresN[86][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[86][2],1,,,,.T.,)

	oCatEs   := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[87][1], aValoresN[87][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[87][2],1,,,,.T.,)

	///////////////////////// ABA 'Outros' ///////////////////////

	oPrior   := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[88][1], aValoresN[88][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@N 9", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[88][2],1,,,,.T.,)

	oIdent   := TComboBox():New( 030, 001, {|u|if(PCount()>0,aValoresN[89][1]:=u,aValoresN[89][1])}, aIdent, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[89][1], aValoresN[89][2], 1, , )

	oRepres  := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[90][1], aValoresN[90][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[90][2],1,,,,.T.,)

	oIdRep   := TComboBox():New( 090, 001, {|u|if(PCount()>0,aValoresN[91][1]:=u,aValoresN[91][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[91][1], aValoresN[91][2], 1, , )

	oFabr    := TComboBox():New( 120, 001, {|u|if(PCount()>0,aValoresN[92][1]:=u,aValoresN[92][1])}, aIdent, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[92][1], aValoresN[92][2], 1, , )

	oCodLoc  := TComboBox():New( 150, 001, {|u|if(PCount()>0,aValoresN[93][1]:=u,aValoresN[93][1])}, aCodLoc, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[93][1], aValoresN[93][2], 1, , )

	oRecCid  := TComboBox():New( 180, 001, {|u|if(PCount()>0,aValoresN[95][1]:=u,aValoresN[95][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[95][1], aValoresN[95][2], 1, , )

	oCodBlo  := TGet():New( 210, 001, {|u| if(PCount()==0, aValoresN[96][1], aValoresN[96][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[96][2],1,,,,.T.,)

	oProdRur := TComboBox():New( 240, 001, {|u|if(PCount()>0,aValoresN[97][1]:=u,aValoresN[97][1])}, aProdRur, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[97][1], aValoresN[97][2], 1, , )

	oLcIss   := TComboBox():New( 270, 001, {|u|if(PCount()>0,aValoresN[99][1]:=u,aValoresN[99][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[99][1], aValoresN[99][2], 1, , )

	oRecFa   := TComboBox():New( 300, 001, {|u|if(PCount()>0,aValoresN[100][1]:=u,aValoresN[100][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[100][1], aValoresN[100][2], 1, , )

	oCCIC    := TComboBox():New( 000, 100, {|u|if(PCount()>0,aValoresN[101][1]:=u,aValoresN[101][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[101][1], aValoresN[101][2], 1, , )

	oRecIma  := TComboBox():New( 030, 100, {|u|if(PCount()>0,aValoresN[102][1]:=u,aValoresN[102][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[102][1], aValoresN[102][2], 1, , )

	oCodFIES := TGet():New( 060, 100, {|u| if(PCount()==0, aValoresN[103][1], aValoresN[103][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[103][2],1,,,,.T.,)

	oRgSimp  := TComboBox():New( 090, 100, {|u|if(PCount()>0,aValoresN[104][1]:=u,aValoresN[104][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[104][1], aValoresN[104][2], 1, , )

	oRetCprb := TComboBox():New( 120, 100, {|u|if(PCount()>0,aValoresN[105][1]:=u,aValoresN[105][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[105][1], aValoresN[105][2], 1, , )

	oIndRur  := TComboBox():New( 150, 100, {|u|if(PCount()>0,aValoresN[106][1]:=u,aValoresN[106][1])}, aIndRural, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[106][1], aValoresN[106][2], 1, , )

	oInCult  := TComboBox():New( 180, 100, {|u|if(PCount()>0,aValoresN[108][1]:=u,aValoresN[108][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[108][1], aValoresN[108][2], 1, , )

	oAssDesp := TComboBox():New( 210, 100, {|u|if(PCount()>0,aValoresN[109][1]:=u,aValoresN[109][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[109][1], aValoresN[109][2], 1, , )

	oCalcInp := TComboBox():New( 240, 100, {|u|if(PCount()>0,aValoresN[110][1]:=u,aValoresN[110][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[110][1], aValoresN[110][2], 1, , )

	oIdentPr := TComboBox():New( 270, 100, {|u|if(PCount()>0,aValoresN[111][1]:=u,aValoresN[111][1])}, aIdentPr, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[111][1], aValoresN[111][2], 1, , )

	oCliente := TComboBox():New( 300, 100, {|u|if(PCount()>0,aValoresN[112][1]:=u,aValoresN[112][1])}, aClientes, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[112][1], aValoresN[112][2], 1, , )

	oSimpNac := TComboBox():New( 060, 300, {|u|if(PCount()>0,aValoresN[113][1]:=u,aValoresN[113][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[113][1], aValoresN[113][2], 1, , )

	//aValoresN[114] TEM QUE VER AINDA

	oRfundes := TComboBox():New( 000, 200, {|u|if(PCount()>0,aValoresN[115][1]:=u,aValoresN[115][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[115][1], aValoresN[115][2], 1, , )

	oIndPres := TGet():New( 030, 200, {|u| if(PCount()==0, aValoresN[116][1], aValoresN[116][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E X", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[116][2],1,,,,.T.,)

	oMjuridi := TComboBox():New( 060, 200, {|u|if(PCount()>0,aValoresN[117][1]:=u,aValoresN[117][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[117][1], aValoresN[117][2], 1, , )

	oCodSc   := TGet():New( 090, 200, {|u| if(PCount()==0, aValoresN[118][1], aValoresN[118][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[118][2],1,,,,.T.,)

	oPesTri  := TComboBox():New( 120, 200, {|u|if(PCount()>0,aValoresN[120][1]:=u,aValoresN[120][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[120][1], aValoresN[120][2], 1, , )

	oBlqTem  := TGet():New( 150, 200, {|u| if(PCount()==0, aValoresN[122][1], aValoresN[122][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[122][2],1,,,,.T.,)

	oCoSiaf  := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[123][1], aValoresN[123][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[123][2],1,,,,.T.,)

	oEndNo   := TComboBox():New( 210, 200, {|u|if(PCount()>0,aValoresN[124][1]:=u,aValoresN[124][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[124][1], aValoresN[124][2], 1, , )

	oMotNif  := TComboBox():New( 240, 200, {|u|if(PCount()>0,aValoresN[125][1]:=u,aValoresN[125][1])}, aMotNif, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[125][1], aValoresN[125][2], 1, , )

	oCliLoj  := TComboBox():New( 270, 200, {|u|if(PCount()>0,aValoresN[126][1]:=u,aValoresN[126][1])}, aClientes, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[126][1], aValoresN[126][2], 1, , )

	oClasPj  := TComboBox():New( 300, 200, {|u|if(PCount()>0,aValoresN[127][1]:=u,aValoresN[127][1])}, aClasPj, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[127][1], aValoresN[127][2], 1, , )

	oCargo   := TGet():New( 030, 300, {|u| if(PCount()==0, aValoresN[128][1], aValoresN[128][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[128][2],1,,,,.T.,)

	oConf    := TComboBox():New( 000, 300, {|u|if(PCount()>0,aValoresN[129][1]:=u,aValoresN[129][1])}, aConf, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[129][1], aValoresN[129][2], 1, , )



	/////////////////////// BOTÃO 'Inserir' ///////////////////////
	oTipo 		  := TComboBox():New( 150, 001, {|u|if(PCount()>0,aValores[8][1]:=u,aValores[8][1])}, aTipos, 100, , oTFolder:aDialogs[1], ,{||verificaCgc(oTipo, @oCGC, @oCbo, @oCnae, @oCivil)} , , , , .T., ,, , , , , , , aValores[8][1], aValores[8][2], 1, , )

	oButton3      := TButton():Create(oJanela, 340 ,1,"Inserir",{||insertDb(aValores, aValoresN, oJanela)},75,20,,,,.T.,,,,,,)

	oJanela:Activate(,,,.T.,,,) 


RETURN


Static Function insertDb(aValores, aValoresN, oJanela)
	Local aValoresFaltantes := verificaValores(aValores)
	Local cValoresTexto := ''
	Local verificaChave
	Local nI
	If Len(aValoresFaltantes) > 0
		For nI := 1 To Len(aValoresFaltantes)
			cValoresTexto += aValoresFaltantes[nI]
			cValoresTexto += ' '
			cValoresTexto += Chr(13)+Chr(10)
		Next
		FWAlertError("Os seguintes valores não podem estar vazios:" + Chr(13)+Chr(10) + cValoresTexto ,"Erro na inserção")
		RETURN
	Endif

	verificaChave := verificacao(aValores[1][1], aValores[2][1])

	If verificaChave != 0
		FWAlertError("Codigo com loja ja existente no banco","Erro na inserção")
		RETURN
	Endif

	dbSelectArea("SA2")
	DBGOTOP()

	RecLock("SA2", .T.)
	A2_COD     := aValores[1][1]     				   // Código
	A2_NOME    := aValores[3][1]      				   // Fantasia
	A2_LOJA    := aValores[2][1]                       // Loja
	A2_TIPO    := Left(aValores[8][1], 1)              // Tipo
	A2_END     := aValores[6][1]                       // Endereço
	A2_EST     := getSiglaEst(aValores[4][1])          // Estado
	A2_MUN 	   := aValores[5][1]                       // Município
	A2_NREDUZ  := aValores[7][1]                       // Razao social
	A2_CGC     := aValoresN[1][1]                      // codigo/cpf
	A2_COD_MUN := trataCodMun(aValoresN[2][1])         // codigo municipio
	A2_TEL     := aValoresN[3][1]                      // telefone
	A2_PFISICA := aValoresN[4][1]                  	   // num registro identificaçao
	A2_INSCR   := aValoresN[5][1]  				       // num. inscricao estad.
	A2_INSCRM  := aValoresN[6][1]  				       // num. inscricao municip.
	A2_PAIS    := trataCodMun(aValoresN[8][1])
	A2_DDI     := aValoresN[7][1]
	A2_DDD	   := aValoresN[9][1]
	A2_DEPTO   := aValoresN[11][1]
	A2_EMAIL   := aValoresN[12][1]
	A2_HPAGE   := aValoresN[13][1]
	A2_TELEX   := aValoresN[14][1]
	A2_ENDCOMP := aValoresN[15][1]
	A2_MSBLQL  := Left(aValoresN[16][1],1) 				// pegando só o 1 ou 2
	A2_COMPLEM := aValoresN[17][1]
	A2_FORNEMA := Left(aValoresN[18][1],1) 				// pegando só o 1 ou 2
	A2_CBO     := aValoresN[19][1]
	A2_CNAE    := aValoresN[20][1]

	//

	A2_BANCO   := aValoresN[21][1]
	A2_AGENCIA := aValoresN[22][1]
	A2_NUMCON  := aValoresN[23][1]
	A2_NATUREZ := aValoresN[24][1]
	A2_COND    := aValoresN[25][1]
	A2_CODADM  := aValoresN[26][1]
	A2_FORMPAG := trataFormaPag(aValoresN[27][1])
	A2_DVCTA   := aValoresN[28][1]
	A2_DVAGE   := aValoresN[29][1]

	//

	A2_TIPORUR := Left(aValoresN[30][1],1)
	A2_RECISS  := Left(aValoresN[31][1],1)
	A2_CODMUN  := trataCodZf(aValoresN[32][1])
	A2_RECINSS := Left(aValoresN[33][1],2)
	A2_TPESSOA := Left(aValoresN[34][1],2)
	A2_CODPAIS := trataCodMun(aValoresN[35][1])
	A2_TPISSRS := aValoresN[36][1]
	A2_GRPTRIB := aValoresN[37][1]
	A2_RECPIS  := Left(aValoresN[38][1],1)
	A2_RECCSLL := Left(aValoresN[39][1],1)
	A2_RECCOFI := Left(aValoresN[40][1],1)
	A2_CALCIRF := Left(aValoresN[41][1],1)
	A2_VINCULO := aValoresN[42][1]
	A2_DTINIV  := aValoresN[43][1]
	A2_DTFIMV  := aValoresN[44][1]
	A2_RFACS   := Left(aValoresN[45][1],1)
	A2_CONTRIB := Left(aValoresN[46][1],1)
	A2_RFABOV  := Left(aValoresN[47][1],1)
	A2_DEDBSPC := Left(aValoresN[48][1],1)
	A2_RECFMD  := Left(aValoresN[49][1],1)
	A2_CPOMSP  := Left(aValoresN[50][1],1)
	A2_SITESBH := Left(aValoresN[51][1],1)
	A2_TPLOGR  := aValoresN[52][1]
	A2_TPJ	   := Left(aValoresN[53][1],1)
	A2_DTCONV  := aValoresN[54][1]
	A2_CTARE := Left(aValoresN[55][1],1)
	A2_RECFET  := Left(aValoresN[56][1],1)
	A2_MINIRF  := Left(aValoresN[57][1],1)
	A2_INCLTMG := Left(aValoresN[58][1],1)
	A2_FOMEZER := Left(aValoresN[59][1],1)
	A2_IRPROG  := Left(aValoresN[60][1],1)
	A2_INOVAUT := Left(aValoresN[61][1],1)
	A2_NOMRESP := aValoresN[62][1]

	//

	A2_CONTATO := aValoresN[63][1]
	A2_TRANSP  := aValoresN[64][1]
	//65
	//66
	A2_CIVIL   := Left(aValoresN[67][1],1)
	//
	A2_RECSEST := Left(aValoresN[68][1],1)

	//

	A2_PAISSUB := aValoresN[69][1]
	A2_TPCON   := aValoresN[70][1]
	A2_NIFEX   := aValoresN[71][1]
	A2_DTFIMR  := aValoresN[72][1]
	A2_DTINIR  := aValoresN[73][1]
	//74
	//75
	//76
	//77
	//78
	//79
	//80
	//81
	//82

	//

	A2_CODNIT := aValoresN[83][1]
	A2_DTNASC := aValoresN[84][1]
	A2_CATEG  := aValoresN[85][1]
	A2_OCORREN := aValoresN[86][1]
	A2_CATEFD := aValoresN[87][1]

	//

	A2_PRIOR := aValoresN[88][1]
	A2_ID_FBFN := Left(aValoresN[89][1],1)
	A2_REPRES := aValoresN[90][1]
	A2_ID_REPR := Left(aValoresN[91][1],1)
	A2_FABRICA := Left(aValoresN[92][1],1)
	A2_CODLOC  := aValoresN[93][1]
	//maior nota
	A2_RECCIDE := Left(aValoresN[95][1],1)
	A2_CODBLO  := aValoresN[96][1]
	A2_INDRUR  := Left(aValoresN[97][1],1)
	//up ficticia
	A2_ISSRSLC := Left(aValoresN[99][1],1)
	A2_RFASEMT := Left(aValoresN[100][1],1)
	A2_CCICMS  := Left(aValoresN[101][1],1)
	A2_RIMAMT  := Left(aValoresN[102][1],1)
	A2_CODFI   := aValoresN[103][1]
	A2_REGESIM := aValoresN[104][1]
	A2_CPRB    := aValoresN[105][1]
	A2_INDCP   := Left(aValoresN[106][1],1)
	A2_INCULT  := Left(aValoresN[108][1],1)
	A2_DESPORT := Left(aValoresN[109][1],1)
	A2_CALCINP := Left(aValoresN[110][1],1)
	A2_IMPIP   := Left(aValoresN[111][1],1)
	A2_CLIENTE := aValoresN[112][1]
	A2_SIMPNAC := Left(aValoresN[113][1],1)
	A2_RFUNDES := Left(aValoresN[115][1],1)
	A2_PRSTSER := aValoresN[116][1]
	A2_MJURIDI := Left(aValoresN[117][1],1)
	A2_MUNSC   := aValoresN[118][1]
	A2_TRIBFAV := Left(aValoresN[120][1],1)
	A2_MSBLQD  := aValoresN[122][1]
	A2_CODSIAF := aValoresN[123][1]
	A2_ENDNOT  := Left(aValoresN[124][1],1)
	A2_MOTNIF  := Left(aValoresN[125][1],1)
	A2_LOJCLI := aValoresN[126][1]
	A2_TPENT  := Left(aValoresN[127][1],1)
	A2_CARGO  := aValoresN[128][1]
	A2_CONFFIS := aValoresN[129][1]

	MsUnlock()

	SA2->(dbCloseArea())

	FWAlertSuccess("Fornecedor inserido com sucesso", "Inserido")
	oJanela:end()


RETURN


Static Function update()
	Local oJanela  := TDialog():New(0, 0, 730, 1100, 'Cadastro de fornecedores', , , , , CLR_BLACK, CLR_WHITE, , , .T.)
	Local nNumero := 0

	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }

	Local aValores := { ;
		{SA2->A2_COD, 'Código'}, ;
		{SA2->A2_LOJA, 'Loja'}, ;
		{SA2->A2_NOME, 'Razão Social'}, ;
		{SA2->A2_EST, 'Estado'}, ;
		{SA2->A2_MUN, 'Municipio'}, ;
		{SA2->A2_END, 'Endereço'}, ;
		{SA2->A2_NREDUZ, 'Nome Fantasia'}, ;
		{A2_TIPO, 'Tipo'} ;
		}

	Local aValoresN := { ;
		{SA2->A2_CGC, 'CPF/CNPJ'}, ;
		{'', 'Código Município'}, ;
		{SA2->A2_TEL, 'Telefone'}, ;
		{SA2->A2_PFISICA, 'RG/Ced.Estr.'}, ;
		{SA2->A2_INSCR, 'Ins. Estad.'}, ;
		{SA2->A2_INSCRM, 'Ins. Municip.'}, ;
		{SA2->A2_DDI, 'DDI'}, ;
		{SA2->A2_PAIS, 'País'}, ;
		{SA2->A2_DDD, 'DDD'}, ;
		{'', 'Descr. País'}, ;
		{SA2->A2_DEPTO, 'Departamento'}, ;
		{SA2->A2_EMAIL, 'Email'}, ;
		{SA2->A2_HPAGE, 'Homepage'}, ;
		{A2_TELEX, 'TELEX'}, ;
		{SA2->A2_ENDCOMP, 'END. COMPLEMENTAR'}, ;
		{SA2->A2_MSBLQL, 'Bloqueado'}, ;
		{SA2->A2_COMPLEM, 'Complemento'}, ;
		{SA2->A2_FORNEMA, 'Forn.Mailing'}, ;
		{SA2->A2_CBO, 'Cod CBO'}, ;
		{SA2->A2_CNAE, 'Cod CNAE'}, ;
		{SA2->A2_BANCO, 'Banco'}, ;
		{SA2->A2_AGENCIA, 'Cod. Agência'}, ;
		{SA2->A2_NUMCON, 'Cta Corrente'}, ;
		{SA2->A2_NATUREZ, 'Natureza'}, ;
		{SA2->A2_COND, 'Cond. Pagto'}, ;
		{SA2->A2_CODADM, 'CodAdm'}, ;
		{SA2->A2_FORMPAG, 'Forma de pagamento'}, ;
		{SA2->A2_DVCTA, 'Dv Cta Cnab'}, ;
		{SA2->A2_DVAGE, 'DV Age Cnab'}, ;
		{SA2->A2_TIPORUR, 'Tp.Contr.Soc'}, ;
		{SA2->A2_RECISS, 'Recolhe ISS'}, ;
		{SA2->A2_CODMUN, 'Cod. Mun. ZF'}, ;
		{SA2->A2_RECINSS, 'Calc. INSS'}, ;
		{SA2->A2_TPESSOA, 'Tipo Pessoa'}, ;
		{SA2->A2_CODPAIS, 'País Bacen'}, ;
		{SA2->A2_TPISSRS, 'Tipo Escr.'}, ;
		{SA2->A2_GRPTRIB, 'Grp. Tribut.'}, ;
		{SA2->A2_RECPIS, 'Rec. PIS'}, ;
		{SA2->A2_RECCSLL, 'Rec.CSLL'}, ;
		{SA2->A2_RECCOFI, 'Rec.COFINS'}, ;
		{SA2->A2_CALCIRF, 'CÁLC. IRRF'}, ;
		{SA2->A2_VINCULO, 'P. VINCULO'}, ;
		{A2_DTINIV, 'DT INI VINCU'}, ;
		{A2_DTFIMV, 'DT FIM VINCU'}, ;
		{SA2->A2_RFACS, 'REC. FACS'}, ;
		{SA2->A2_CONTRIB, 'Contribuinte'}, ;
		{SA2->A2_RFABOV, 'REC. FABOV'}, ;
		{SA2->A2_DEDBSPC, 'DED. PIS/COF'}, ;
		{SA2->A2_RECFMD, 'REC. FAMAD'}, ;
		{SA2->A2_CPOMSP, 'REG. CPOM'}, ;
		{SA2->A2_SITESBH, 'SITESPRES BH'}, ;
		{SA2->A2_TPLOGR, 'TP. LOGRAD'}, ;
		{SA2->A2_TPJ, 'TPJ'}, ;
		{SA2->A2_DTCONV, 'Dt. Conv'}, ;
		{SA2->A2_CTARE, 'Contr TARE?'}, ;
		{SA2->A2_RECFET, 'Rec. FETHAB'}, ;
		{SA2->A2_MINIRF, 'Vlr. Min. IR'}, ;
		{SA2->A2_INCLTMG, 'Inc.Prd.Leit'}, ;
		{SA2->A2_FOMEZER, 'Fome Zero'}, ;
		{SA2->A2_IRPROG, 'IRRF Prog'}, ;
		{SA2->A2_INOVAUT, 'Inovar Auto'}, ;
		{SA2->A2_NOMRESP, 'Nome Resp.'}, ;
		{SA2->A2_CONTATO, 'Contato'}, ;
		{SA2->A2_TRANSP, 'Transp.'}, ;
		{'', '1a Compra'}, ;
		{'', 'Ult Compra'}, ;
		{SA2->A2_CIVIL, 'Estado Civil'}, ;
		{SA2->A2_RECSEST, 'Recolhe SEST'},  ;
		{SA2->A2_PAISSUB, 'SubDivPais'},  ;
		{SA2->A2_TPCON, 'Tipo Contrat'},  ;
		{SA2->A2_NIFEX, 'Codigo NIF'},  ;
		{SA2->A2_DTFIMR, 'Data Fim'},  ;
		{SA2->A2_DTINIR, 'Data Inicio'}, ;
		{'', 'Benef. Rend.'},  ;
		{'', 'Est./Prov.'},  ;
		{'', 'Forma Trib'},  ;
		{'', 'Logradouro'},  ;
		{'', 'Complemento'},  ;
		{'', 'Bairro/Dist.'},  ;
		{'', 'Rendimento'},  ;
		{'', 'Cidade'},  ;
		{'', 'CNPJ Empr.Ex'},  ;
		{SA2->A2_CODNIT, 'Num Insc Aut'},  ;
		{SA2->A2_DTNASC, 'Data nasc.'},  ;
		{SA2->A2_CATEG, 'Categ. SEFIP'},  ;
		{SA2->A2_OCORREN, 'Ocorrência'},  ;
		{SA2->A2_CATEFD, 'Cat eSocial'},  ;
		{SA2->A2_PRIOR, 'Prioridade'},  ;
		{SA2->A2_ID_FBFN, 'Identificac.'},  ;
		{SA2->A2_REPRES, 'Represent.'}, ;
		{SA2->A2_ID_REPR, 'Identif.Repr.'}, ;
		{SA2->A2_FABRICA, 'Fabricante'}, ;
		{SA2->A2_CODLOC, 'Cod.Local'},  ;
		{'', 'Maior Nota'},  ;
		{SA2->A2_RECCIDE, 'Rec Cide'},  ;
		{SA2->A2_CODBLO, 'Cod.Bloqueio'},  ;
		{SA2->A2_INDRUR,'Ind. Prod. Rur'}, ;
		{'','UF Ficticia'}, ;
		{SA2->A2_ISSRSLC,'LC ISS RS'}, ;
		{SA2->A2_RFASEMT,'Rec.FASE-MT'}, ;
		{SA2->A2_CCICMS,'CCICMS'}, ;
		{SA2->A2_RIMAMT,'Rec. IMA-MT'}, ;
		{SA2->A2_CODFI,'Cod. FIESP'}, ;
		{SA2->A2_REGESIM,'Rg. Simp. MT'}, ;
		{SA2->A2_CPRB,'Ret. CPRB'}, ;
		{SA2->A2_INDCP, 'Ind. Rural'}, ;
		{'', 'Ident.Exp.'}, ;
		{SA2->A2_INCULT, 'Inc. Cultura'}, ;
		{SA2->A2_DESPORT, 'Assoc. Desp.'}, ;
		{SA2->A2_CALCINP, 'Calc.INSS.Pt'}, ;
		{SA2->A2_IMPIP, 'Ident.Prod.'}, ;
		{SA2->A2_CLIENTE, 'Cód. Cliente'}, ;
		{SA2->A2_SIMPNAC, 'Opt Simp Nac'}, ;
		{'', 'Cód Func'}, ;
		{SA2->A2_RFUNDES,'Rec.FUNDESA'}, ;
		{SA2->A2_PRSTSER,'Ind. Prest.'}, ;
		{SA2->A2_MJURIDI,'M.Jurídico'}, ;
		{SA2->A2_MUNSC,'Cod Mun SC'},;
		{'','CPF Rural'}, ;
		{SA2->A2_TRIBFAV,'Pes.Tri.Fav'}, ;
		{'','Fil. Transf.'}, ;
		{SA2->A2_MSBLQD,'BlqTemporal'}, ;
		{SA2->A2_CODSIAF,'Cod.Mun.SIAF'}, ;
		{SA2->A2_ENDNOT,'End.Not.Form'}, ;
		{SA2->A2_MOTNIF, 'Mot.NIF'},;
		{SA2->A2_LOJCLI, 'Loja Cliente'},;
		{SA2->A2_TPENT, 'Clas.PJ'},;
		{SA2->A2_CARGO, 'Cargo Resp.'},;
		{SA2->A2_CONFFIS, 'Conf. Física'};
		}

	Local aTipos := { "F - Físico", "J - Jurídico" }
	Local aClientes := getClientes()
	Local aClasPj := {"1 - Imune", "2 - Isento"}
	Local aCivil := { "1 - Solteiro", "2 - Casado", "3 - Divorciado", "4 - Viuvo", "5 - Companheiro(a)", "x - Anonimizado", "" }
	Local aTpj := { '1 - ME - Micro Empresa', '2 - EPP - Empresas de Pequeno Porte', '3 - MEI - Microempreendedor Individual', '4 - Cooperativa', '5 - Não optante' }
	Local aSitEspRes := { '1 - Ex Pr bde Ser', '2 - Pr de Ser c/ Ded', '3 - Con Civ', '4 - Ag de Tu/Adm Fun', '5 - Pro e Pub/Int', '6 - Pro e Pub/Int Is', '7 - Não In/Re/Rep' }
	Local aIndRural := {"1 - Sobre a comercializacao da sua producao","2 - Sobre a folha de pagamento"}
	Local aPisCof := { '1 - Legado', '2 - ICMS e IPI', '3 - ICMS', '4 - IPI', '5 - Nenhum', '6 - Soma IPI' }
	Local aCalcsIRFF := { "1 - Normal", "2 - IRFF Baixa", "3 - Simples", "4 - Empresa Individual" }
	Local aInovaut := { "1 - Participa", "2 - Não Participa", "3 - Convidar" }
	Local aIdentPr := { "1 - Pedido Compra", "2 - Recebimento", "3 - Nao Imprime", "4 - Documento Entrada" }
	Local aTiposVerificacao := { "F", "J" }
	Local aMotNif := {"1 - Dispensado do NIF", "2 - País não exige NIF"}
	Local aConf := {"0 - Parâmetro","1 - Pré-Nota","2 - Nota Fiscal","3 - Não utiliza"}
	Local aProdRur := { "0 - Não é prod.rural", "1 - Seg.Espec.Geral PF", "2 - Seg.Espec.Ent.PAA PF", "3 - Ent.PAA PJ" }
	Local aEstados := FWGetSX5("12")
	Local aEstadosSiglas := {}
	Local aOpVinculo := getOpVinculo()
	Local aCodLoc := getCodLoc()
	Local aEstados2 := {}
	Local aMunicipios := {}
	Local aSimNao := { "2 - Não", "1 - Sim" }
	Local aNaoSim := { "1 - Sim", "2 - Não" }
	Local aContr := { "J - Jurídico", "F - Pessoa Fisica", "L - Familiar" }
	Local aIdent := getIdent()
	Local aNaturezas := getNatCondAdm("SED")
	Local aCondominios := getNatCondAdm("SE4")
	Local aCodAdms := getNatCondAdm("SAE")
	Local aPagtos := getPagtos()
	Local aPaises := trataPaises()
	Local aTransp := getTransportadora()
	Local aTipoPessoa := { "CI - Comercio/Industria", "PF - Pessoa Fisica", "OS - Prestacao de Servico" }
	Local aZF := getZF()

	Local oTFolder := TFolder():New(0, 0, aTFolder, , oJanela, , , , .T., , 551, 730)

	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next

	For nNumero := 1 to 26
		AADD(aEstadosSiglas, AllTrim(aEstados[nNumero][3]))
	next

	aValoresN[10][1] := getPaisFromCod(A2_PAIS)

	/////////////////////// ABA 'Cadastrais' ///////////////////////

	oCodigo       := TGet():New( 0, 1, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)},oTFolder:aDialogs[1], 096, 009, "@N 9999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oCGC		  := TGet():New( 0, 100, {|u|if(PCount()==0,aValoresN[1][1],aValoresN[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 999.999.999-99",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[1][1],,,,,,,aValoresN[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 20, 1, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oNFantasia    := TGet():New( 40, 1, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oTelefone     := TGet():New( 40, 100, {|u|if(PCount()==0,aValoresN[3][1],aValoresN[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 9999-9999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[3][1],,,,,,,aValoresN[3][2],1,,,,.T.,)

	oCodMun		  := TComboBox():New( 20, 100, {|u|if(PCount()>0,aValoresN[2][1]:=u,aValoresN[2][1])}, aMunicipios, 100, , oTFolder:aDialogs[1], , , , , , .T., ,, , , , , , , aValoresN[2][1], aValoresN[2][2], 1, , )

	OPFisica 	  := TGet():New( 060, 100, {|u|if(PCount()==0,aValoresN[4][1],aValoresN[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[4][1],,,,,,,aValoresN[4][2],1,,,,.T.,)

	oEstado       := TComboBox():New( 60, 1, {|u|if(PCount()>0,aValores[4][1]:=u,aValores[4][1])}, aEstados2, 100, , oTFolder:aDialogs[1], ,{||getComboMunicipios(oEstado, @oCodMun)} , , , , .T., ,, , , , , , , aValores[4][1], 'Estado', 1, , )
	oEstado:Select(aScan(aEstadosSiglas, SA2->A2_EST))

	aMunicipios := getMunicipios(oEstado)
	oCodMun:setItems(aMunicipios)
	oCodMun:Select(aScan(aMunicipios, getNomeMun(SA2->A2_COD_MUN,SA2->A2_EST)))

	oInscr 		  := TGet():New( 085, 100, {|u|if(PCount()==0,aValoresN[5][1],aValoresN[5][1]:=u)},oTFolder:aDialogs[1], 096, 009, "@N 99999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[5][1],,,,,,,aValoresN[5][2],1,,,,.T.,)

	oMunicipio    := TGet():New( 085, 1, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 1, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oInscrM 	  := TGet():New( 105, 100, {|u|if(PCount()==0,aValoresN[6][1],aValoresN[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[6][1],,,,,,,aValoresN[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 1, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)

	oDdi          := TGet():New( 125, 100, {|u|if(PCount()==0,aValoresN[7][1],aValoresN[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[7][1],,,,,,,aValoresN[7][2],1,,,,.T.,)

	oDdd          := TGet():New( 150, 100, {|u|if(PCount()==0,aValoresN[9][1],aValoresN[9][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[9][1],,,,,,,aValoresN[9][2],1,,,,.T.,)

	oDescPais	  := TGet():New( 200, 100, {|u|if(PCount()==0,aValoresN[10][1],aValoresN[10][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[10][1],,,,,,,aValoresN[10][2],1,,,,.T.,)

	oPais 		  := TComboBox():New( 180, 001, {|u|if(PCount()>0,aValoresN[8][1]:=u,aValoresN[8][1])}, aPaises, 200, , oTFolder:aDialogs[1], ,{|| trocaDescPais(aValoresN[8][1], @oDescPais)}, , , , .T., ,, , , , , , , aValoresN[8][1], aValoresN[8][2], 1, , )
	selecionaPais(@oPais,SA2->A2_PAIS,aPaises)

	oDept 		  := TGet():New( 000, 200, {|u| if(PCount()==0, aValoresN[11][1], aValoresN[11][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[11][1],,,,,,, aValoresN[11][2],1,,,,.T.,)

	oEmail 		  := TGet():New( 020, 200, {|u| if(PCount()==0, aValoresN[12][1], aValoresN[12][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[12][1],,,,,,, aValoresN[12][2],1,,,,.T.,)

	oHpage 		  := TGet():New( 040, 200, {|u| if(PCount()==0, aValoresN[13][1], aValoresN[13][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[13][1],,,,,,, aValoresN[13][2],1,,,,.T.,)

	oTelex 		  := TGet():New( 060, 200, {|u| if(PCount()==0, aValoresN[14][1], aValoresN[14][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[14][1],,,,,,, aValoresN[14][2],1,,,,.T.,)

	oEndcomp 	  := TGet():New( 080, 200, {|u| if(PCount()==0, aValoresN[15][1], aValoresN[15][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[15][1],,,,,,, aValoresN[15][2],1,,,,.T.,)

	oBloq         := TComboBox():New( 100, 200, {|u|if(PCount()>0,aValoresN[16][1]:=u,aValoresN[16][1])}, aSimNao, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[16][1], aValoresN[16][2], 1, , )
	selecionaSimNao(@oBloq, SA2->A2_MSBLQL)

	oComplem      := TGet():New( 120, 200, {|u| if(PCount()==0, aValoresN[17][1], aValoresN[17][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[17][1],,,,,,, aValoresN[17][2],1,,,,.T.,)

	oForm         := TComboBox():New( 140, 200, {|u|if(PCount()>0,aValoresN[18][1]:=u,aValoresN[18][1])}, aSimNao, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[18][1], aValoresN[18][2], 1, , )
	selecionaSimNao(@oForm, SA2->A2_FORNEMA)

	oCbo		  := TGet():New( 160, 200, {|u| if(PCount()==0, aValoresN[19][1], aValoresN[19][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[19][1],,,,,,, aValoresN[19][2],1,,,,.T.,)

	oCnae 		  := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[20][1], aValoresN[20][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999-9/9999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[20][1],,,,,,, aValoresN[20][2],1,,,,.T.,)

	/////////////////////// ABA 'Adm/Fin.' ///////////////////////
	oBanco		  := TGet():New( 000, 001, {|u|if(PCount()==0,aValoresN[21][1],aValoresN[21][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[21][1],,,,,,,aValoresN[21][2],1,,,,.T.,)

	oCodAgencia	  := TGet():New( 020, 001, {|u|if(PCount()==0,aValoresN[22][1],aValoresN[22][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[22][1],,,,,,,aValoresN[22][2],1,,,,.T.,)

	oCtCorrente	  := TGet():New( 040, 001, {|u|if(PCount()==0,aValoresN[23][1],aValoresN[23][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[23][1],,,,,,,aValoresN[23][2],1,,,,.T.,)

	oNatureza     := TComboBox():New( 060, 001, {|u|if(PCount()>0,aValoresN[24][1]:=u,aValoresN[24][1])}, aNaturezas, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[24][1], aValoresN[24][2], 1, , )
	oNatureza:Select(aScan(aNaturezas, AllTrim(SA2->A2_NATUREZ)))

	oCondominio   := TComboBox():New( 080, 001, {|u|if(PCount()>0,aValoresN[25][1]:=u,aValoresN[25][1])}, aCondominios, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[25][1], aValoresN[25][2], 1, , )
	oCondominio:Select(aScan(aCondominios, AllTrim(SA2->A2_COND)))

	oCodAdm		  := TComboBox():New( 100, 001, {|u|if(PCount()>0,aValoresN[26][1]:=u,aValoresN[26][1])}, aCodAdms, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[26][1], aValoresN[26][2], 1, , )
	oCodAdm:Select(aScan(aCodAdms, AllTrim(SA2->A2_CODADM)))

	oFormPagto	  := TComboBox():New( 120, 001, {|u|if(PCount()>0,aValoresN[27][1]:=u,aValoresN[27][1])}, aPagtos, 100, , oTFolder:aDialogs[2], ,, , , , .T., ,, , , , , , , aValoresN[27][1], aValoresN[27][2], 1, , )
	selecionaFormPagto(@oFormPagto, SA2->A2_FORMPAG)

	oDvcta        := TGet():New( 140, 001, {|u| if(PCount()==0, aValoresN[28][1], aValoresN[28][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@N 99", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[28][1],,,,,,, aValoresN[28][2],1,,,,.T.,)

	oDvAg         := TGet():New( 160, 001, {|u| if(PCount()==0, aValoresN[29][1], aValoresN[29][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E X", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[29][1],,,,,,, aValoresN[29][2],1,,,,.T.,)

	/////////////////////// ABA 'Fiscais' ///////////////////////

	oTipoContr	  := TComboBox():New( 000, 001, {|u|if(PCount()>0,aValoresN[30][1]:=u,aValoresN[30][1])}, aContr, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[30][1], aValoresN[30][2], 1, , )
	selecionaTipoRUR(@oTipoContr, SA2->A2_TIPORUR)

	oRecIss		  := TComboBox():New( 020, 001, {|u|if(PCount()>0,aValoresN[31][1]:=u,aValoresN[31][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[31][1], aValoresN[31][2], 1, , )
	selecionaNaoSim(@oRecIss, SA2->A2_RECISS)

	oCodMunZf	  := TComboBox():New( 040, 001, {|u|if(PCount()>0,aValoresN[32][1]:=u,aValoresN[32][1])}, aZF, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[32][1], aValoresN[32][2], 1, , )
	updateZf(@oCodMunZf, SA2->A2_CODMUN)

	oCalcInss 	  := TComboBox():New( 060, 001, {|u|if(PCount()>0,aValoresN[33][1]:=u,aValoresN[33][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[33][1], aValoresN[33][2], 1, , )
	selecionaNaoSim(@oCalcInss, SA2->A2_RECINSS)

	oTPessoa	  := TComboBox():New( 080, 001, {|u|if(PCount()>0,aValoresN[34][1]:=u,aValoresN[34][1])}, aTipoPessoa, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[34][1], aValoresN[34][2], 1, , )
	updateTipoPessoa(@oTPessoa, SA2->A2_TPESSOA)

	oPaisBacen    := TComboBox():New( 100, 001, {|u|if(PCount()>0,aValoresN[35][1]:=u,aValoresN[35][1])}, aPaises, 150, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[35][1], aValoresN[35][2], 1, , )
	selecionaPais(@oPaisBacen,SA2->A2_CODPAIS,aPaises)

	oTipoEscr	  := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[36][1], aValoresN[36][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@N 99",{|| verificaTipoEscr(@oTipoEscr)} ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[36][1],,,,,,, aValoresN[36][2],1,,,,.T.,)

	oGrpTrib 	  := TGet():New( 140, 001, {|u| if(PCount()==0, aValoresN[37][1], aValoresN[37][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[37][1],,,,,,, aValoresN[37][2],1,,,,.T.,)

	oRecPis	  	  := TComboBox():New( 160, 001, {|u|if(PCount()>0,aValoresN[38][1]:=u,aValoresN[38][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[38][1], aValoresN[38][2], 1, , )
	selecionaNaoSim(@oRecPis, SA2->A2_RECPIS)

	oRecCSLL   	  := TComboBox():New( 180, 001, {|u|if(PCount()>0,aValoresN[39][1]:=u,aValoresN[39][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[39][1], aValoresN[39][2], 1, , )
	selecionaNaoSim(@oRecCSLL, SA2->A2_RECCSLL)

	oRecCofins    := TComboBox():New( 200, 001, {|u|if(PCount()>0,aValoresN[40][1]:=u,aValoresN[40][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[40][1], aValoresN[40][2], 1, , )
	selecionaNaoSim(@oRecCofins, SA2->A2_RECCOFI)

	oCalcIRRF     := TComboBox():New( 000, 100, {|u|if(PCount()>0,aValoresN[41][1]:=u,aValoresN[41][1])}, aCalcsIRFF, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[41][1], aValoresN[41][2], 1, , )
	selecionaVal(oCalcIRRF, SA2->A2_CALCIRF, aCalcsIRFF)

	oPVinculo     := TComboBox():New( 030, 100, {|u|if(PCount()>0,aValoresN[42][1]:=u,aValoresN[42][1])}, aOpVinculo, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[42][1], aValoresN[42][2], 1, , )
	selecionaVal(oPVinculo, SA2->A2_VINCULO, aOpVinculo)

	oDtIniV    := TGet():New( 060, 100, {|u| if(PCount()==0, aValoresN[43][1], aValoresN[43][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[43][2],1,,,,.T.,)

	oDtFimV    := TGet():New( 090, 100, {|u| if(PCount()==0, aValoresN[44][1], aValoresN[44][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[44][2],1,,,,.T.,)

	oRecFacs   := TComboBox():New( 120, 100, {|u|if(PCount()>0,aValoresN[45][1]:=u,aValoresN[45][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[45][1], aValoresN[45][2], 1, , )
	selecionaNaoSim(oRecFacs, SA2->A2_RFACS)

	oContrib   := TComboBox():New( 150, 100, {|u|if(PCount()>0,aValoresN[46][1]:=u,aValoresN[46][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[46][1], aValoresN[46][2], 1, , )
	selecionaNaoSim(oContrib, SA2->A2_CONTRIB)

	oRecFabov  := TComboBox():New( 180, 100, {|u|if(PCount()>0,aValoresN[47][1]:=u,aValoresN[47][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[47][1], aValoresN[47][2], 1, , )
	selecionaNaoSim(oRecFabov, SA2->A2_RFABOV)

	oDedPis    := TComboBox():New( 210, 100, {|u|if(PCount()>0,aValoresN[48][1]:=u,aValoresN[48][1])}, aPisCof, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[48][1], aValoresN[48][2], 1, , )
	selecionaVal(oDedPis, SA2->A2_DEDBSPC, aPisCof)

	oRecFmd    := TComboBox():New( 240, 100, {|u|if(PCount()>0,aValoresN[49][1]:=u,aValoresN[49][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[49][1], aValoresN[49][2], 1, , )
	selecionaNaoSim(oRecFmd, SA2->A2_RECFMD)

	oRecCpom   := TComboBox():New( 270, 100, {|u|if(PCount()>0,aValoresN[50][1]:=u,aValoresN[50][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[50][1], aValoresN[50][2], 1, , )
	selecionaNaoSim(oRecCpom, SA2->A2_CPOMSP)

	oSitEspRes := TComboBox():New( 300, 100, {|u|if(PCount()>0,aValoresN[51][1]:=u,aValoresN[51][1])}, aSitEspRes, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[51][1], aValoresN[51][2], 1, , )
	selecionaVal(oSitEspRes, SA2->A2_SITESBH, aSitEspRes)

	oTpLograd  := TGet():New( 000, 200, {|u| if(PCount()==0, aValoresN[52][1], aValoresN[52][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[52][1],,,,,,, aValoresN[52][2],1,,,,.T.,)

	oTpj       := TComboBox():New( 030, 200, {|u|if(PCount()>0,aValoresN[53][1]:=u,aValoresN[53][1])}, aTpj, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[53][1], aValoresN[53][2], 1, , )
	selecionaVal(oTpj, SA2->A2_TPJ, aTpj)

	oDtConv    := TGet():New( 060, 200, {|u| if(PCount()==0, aValoresN[54][1], aValoresN[54][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[54][2],1,,,,.T.,)

	oCTare     := TComboBox():New( 090, 200, {|u|if(PCount()>0,aValoresN[55][1]:=u,aValoresN[55][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[55][1], aValoresN[55][2], 1, , )
	selecionaNaoSim(oCTare, SA2->A2_SITESBH)

	oRecFet    := TComboBox():New( 120, 200, {|u|if(PCount()>0,aValoresN[56][1]:=u,aValoresN[56][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[56][1], aValoresN[56][2], 1, , )
	selecionaNaoSim(oRecFet, SA2->A2_RECFET)

	oVlrMinIr  := TComboBox():New( 150, 200, {|u|if(PCount()>0,aValoresN[57][1]:=u,aValoresN[57][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[57][1], aValoresN[57][2], 1, , )
	selecionaNaoSim(oVlrMinIr, SA2->A2_MINIRF)

	oIncPdrLei := TComboBox():New( 180, 200, {|u|if(PCount()>0,aValoresN[58][1]:=u,aValoresN[58][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[58][1], aValoresN[58][2], 1, , )
	selecionaNaoSim(oIncPdrLei, SA2->A2_INCLTMG)

	oFomeZer   := TComboBox():New( 210, 200, {|u|if(PCount()>0,aValoresN[59][1]:=u,aValoresN[59][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[59][1], aValoresN[59][2], 1, , )
	selecionaNaoSim(oFomeZer, SA2->A2_FOMEZER)

	oIRProg    := TComboBox():New( 240, 200, {|u|if(PCount()>0,aValoresN[60][1]:=u,aValoresN[60][1])}, aNaoSim, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[60][1], aValoresN[60][2], 1, , )
	selecionaNaoSim(oIRProg, SA2->A2_IRPROG)

	oInovaut   := TComboBox():New( 270, 200, {|u|if(PCount()>0,aValoresN[61][1]:=u,aValoresN[61][1])}, aInovaut, 100, , oTFolder:aDialogs[3], ,, , , , .T., ,, , , , , , , aValoresN[61][1], aValoresN[61][2], 1, , )
	selecionaVal(oInovaut, sa2->A2_INOVAUT, aInovaut)

	oNomResp   := TGet():New( 300, 200, {|u| if(PCount()==0, aValoresN[62][1], aValoresN[62][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[62][2],1,,,,.T.,)

	/////////////////////// ABA 'Compras' ///////////////////////

	oContato   := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[63][1], aValoresN[63][1]:=u)}, oTFolder:aDialogs[4], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[63][2],1,,,,.T.,)

	oTransp    := TComboBox():New( 030, 001, {|u|if(PCount()>0,aValoresN[64][1]:=u,aValoresN[64][1])}, aTransp, 100, , oTFolder:aDialogs[4], ,, , , , .T., ,, , , , , , , aValoresN[64][1], aValoresN[64][2], 1, , )
	selecionaVal(oTransp, SA2->A2_TRANSP,aTransp)

	/////////////////////// ABA 'Compras' ///////////////////////

	oCivil     := TComboBox():New( 000, 001, {|u|if(PCount()>0,aValoresN[67][1]:=u,aValoresN[67][1])}, aCivil, 100, , oTFolder:aDialogs[5], ,, , , , .T., ,, , , , , , , aValoresN[67][1], aValoresN[67][2], 1, , )
	selecionaVal(oCivil, SA2->A2_CIVIL,aCivil)

	oTipo  := TComboBox():New( 150, 001, {|u|if(PCount()>0,aValores[8][1]:=u,aValores[8][1])}, aTipos, 100, , oTFolder:aDialogs[1], ,{||verificaCgc(oTipo, @oCGC, @oCbo, @oCnae, @oContato)} , , , , .T., ,, , , , , , , aValores[8][1], aValores[8][2], 1, , )
	oTipo:Select(AScan(aTiposVerificacao, SA2->A2_TIPO))
	verificaCgc(oTipo, @oCGC, @oCbo, @oCnae, @oContato)

	/////////////////////// ABA 'TMS' ///////////////////////

	oSest    := TComboBox():New( 000, 001, {|u|if(PCount()>0,aValoresN[68][1]:=u,aValoresN[68][1])}, aNaoSim, 100, , oTFolder:aDialogs[6], ,, , , , .T., ,, , , , , , , aValoresN[68][1], aValoresN[68][2], 1, , )
	selecionaNaoSim(oSest, SA2->A2_RECSEST)

	///////////////////////// ABA 'Residente Exterior' ///////////////////////

	oSubDiv  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[69][1], aValoresN[69][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@E XXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[69][2],1,,,,.T.,)

	oTipoCon := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[70][1], aValoresN[70][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[70][2],1,,,,.T.,)

	oCodNif  := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[71][1], aValoresN[71][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@N 99999999999999999999999999999999999999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[71][2],1,,,,.T.,)

	oDataFim := TGet():New( 090, 001, {|u| if(PCount()==0, aValoresN[72][1], aValoresN[72][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[72][2],1,,,,.T.,)

	oDataIni := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[73][1], aValoresN[73][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[73][2],1,,,,.T.,)

	///////////////////////// ABA 'Autônomos' ///////////////////////

	oSubDiv  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[83][1], aValoresN[83][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@R 9999.9999.999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[83][2],1,,,,.T.,)

	oDataN   := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[84][1], aValoresN[84][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[84][2],1,,,,.T.,)

	oSefip   := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[85][1], aValoresN[85][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[85][2],1,,,,.T.,)

	oOcorr   := TGet():New( 090, 001, {|u| if(PCount()==0, aValoresN[86][1], aValoresN[86][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[86][2],1,,,,.T.,)

	oCatEs   := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[87][1], aValoresN[87][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[87][2],1,,,,.T.,)

	///////////////////////// ABA 'Outros' ///////////////////////

	oPrior   := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[88][1], aValoresN[88][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@N 9", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[88][2],1,,,,.T.,)

	oIdent   := TComboBox():New( 030, 001, {|u|if(PCount()>0,aValoresN[89][1]:=u,aValoresN[89][1])}, aIdent, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[89][1], aValoresN[89][2], 1, , )

	oRepres  := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[90][1], aValoresN[90][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[90][2],1,,,,.T.,)

	oIdRep   := TComboBox():New( 090, 001, {|u|if(PCount()>0,aValoresN[91][1]:=u,aValoresN[91][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[91][1], aValoresN[91][2], 1, , )
	selecionaNaoSim(oIdRep, SA2->A2_ID_REPR)

	oFabr    := TComboBox():New( 120, 001, {|u|if(PCount()>0,aValoresN[92][1]:=u,aValoresN[92][1])}, aIdent, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[92][1], aValoresN[92][2], 1, , )
	selecionaVal(oFabr, SA2->A2_FABRICA, aIdent)

	oCodLoc  := TComboBox():New( 150, 001, {|u|if(PCount()>0,aValoresN[93][1]:=u,aValoresN[93][1])}, aCodLoc, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[93][1], aValoresN[93][2], 1, , )
	selecionaVal(oCodLoc, SA2->A2_CODLOC, aCodLoc)

	oRecCid  := TComboBox():New( 180, 001, {|u|if(PCount()>0,aValoresN[95][1]:=u,aValoresN[95][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[95][1], aValoresN[95][2], 1, , )
	selecionaNaoSim(oRecCid, SA2->A2_RECCIDE)

	oCodBlo  := TGet():New( 210, 001, {|u| if(PCount()==0, aValoresN[96][1], aValoresN[96][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[96][2],1,,,,.T.,)

	oProdRur := TComboBox():New( 240, 001, {|u|if(PCount()>0,aValoresN[97][1]:=u,aValoresN[97][1])}, aProdRur, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[97][1], aValoresN[97][2], 1, , )
	selecionaVal(oProdrur, SA2->A2_INDRUR, aProdrur)

	oLcIss   := TComboBox():New( 270, 001, {|u|if(PCount()>0,aValoresN[99][1]:=u,aValoresN[99][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[99][1], aValoresN[99][2], 1, , )
	selecionaNaoSim(oLcIss, SA2->A2_ISSRSLC)

	oRecFa   := TComboBox():New( 300, 001, {|u|if(PCount()>0,aValoresN[100][1]:=u,aValoresN[100][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[100][1], aValoresN[100][2], 1, , )
	selecionaNaoSim(oRecFa, SA2->A2_RFASEMT)

	oCCIC    := TComboBox():New( 000, 100, {|u|if(PCount()>0,aValoresN[101][1]:=u,aValoresN[101][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[101][1], aValoresN[101][2], 1, , )
	selecionaNaoSim(oCCIC, SA2->A2_CCICMS)

	oRecIma  := TComboBox():New( 030, 100, {|u|if(PCount()>0,aValoresN[102][1]:=u,aValoresN[102][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[102][1], aValoresN[102][2], 1, , )
	selecionaNaoSim(oRecIma, SA2->A2_RIMAMT)

	oCodFIES := TGet():New( 060, 100, {|u| if(PCount()==0, aValoresN[103][1], aValoresN[103][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[103][2],1,,,,.T.,)

	oRgSimp  := TComboBox():New( 090, 100, {|u|if(PCount()>0,aValoresN[104][1]:=u,aValoresN[104][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[104][1], aValoresN[104][2], 1, , )
	selecionaNaoSim(oRgSimp, SA2->A2_REGESIM)

	oRetCprb := TComboBox():New( 120, 100, {|u|if(PCount()>0,aValoresN[105][1]:=u,aValoresN[105][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[105][1], aValoresN[105][2], 1, , )
	selecionaNaoSim(oRecFa, SA2->A2_CPRB)

	oIndRur  := TComboBox():New( 150, 100, {|u|if(PCount()>0,aValoresN[106][1]:=u,aValoresN[106][1])}, aIndRural, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[106][1], aValoresN[106][2], 1, , )
	selecionaVal(oIndRur, SA2->A2_INDRUR, aIndRural)

	oInCult  := TComboBox():New( 180, 100, {|u|if(PCount()>0,aValoresN[108][1]:=u,aValoresN[108][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[108][1], aValoresN[108][2], 1, , )
	selecionaNaoSim(oInCult, SA2->A2_INCULT)

	oAssDesp := TComboBox():New( 210, 100, {|u|if(PCount()>0,aValoresN[109][1]:=u,aValoresN[109][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[109][1], aValoresN[109][2], 1, , )
	selecionaNaoSim(oAssDesp, SA2->A2_DESPORT)

	oCalcInp := TComboBox():New( 240, 100, {|u|if(PCount()>0,aValoresN[110][1]:=u,aValoresN[110][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[110][1], aValoresN[110][2], 1, , )
	selecionaNaoSim(oCalcInp, SA2->A2_CALCINP)

	oIdentPr := TComboBox():New( 270, 100, {|u|if(PCount()>0,aValoresN[111][1]:=u,aValoresN[111][1])}, aIdentPr, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[111][1], aValoresN[111][2], 1, , )
	selecionaVal(oIdentPr, SA2->A2_IMPIP, aIdentPr)

	oCliente := TComboBox():New( 300, 100, {|u|if(PCount()>0,aValoresN[112][1]:=u,aValoresN[112][1])}, aClientes, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[112][1], aValoresN[112][2], 1, , )
	oCliente:Select(selecionaCliente(aValoresN[112][1], aClientes))

	oSimpNac := TComboBox():New( 060, 300, {|u|if(PCount()>0,aValoresN[113][1]:=u,aValoresN[113][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[113][1], aValoresN[113][2], 1, , )
	selecionaNaoSim(oSimpNac, SA2->A2_SIMPNAC)

	//114 AINDA VAI 

	oRfundes := TComboBox():New( 000, 200, {|u|if(PCount()>0,aValoresN[115][1]:=u,aValoresN[115][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[115][1], aValoresN[115][2], 1, , )
	selecionaNaoSim(orFundes, SA2->A2_RFUNDES)

	oIndPres := TGet():New( 030, 200, {|u| if(PCount()==0, aValoresN[116][1], aValoresN[116][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E X", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[116][2],1,,,,.T.,)

	oMjuridi := TComboBox():New( 060, 200, {|u|if(PCount()>0,aValoresN[117][1]:=u,aValoresN[117][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[117][1], aValoresN[117][2], 1, , )
	selecionaNaoSim(oMjuridi, SA2->A2_MJURIDI)

	oCodSc   := TGet():New( 090, 200, {|u| if(PCount()==0, aValoresN[118][1], aValoresN[118][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[118][2],1,,,,.T.,)

	oPesTri  := TComboBox():New( 120, 200, {|u|if(PCount()>0,aValoresN[120][1]:=u,aValoresN[120][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[120][1], aValoresN[120][2], 1, , )
	selecionaNaoSim(oPesTri, SA2->A2_TRIBFAV)

	oBlqTem  := TGet():New( 150, 200, {|u| if(PCount()==0, aValoresN[122][1], aValoresN[122][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[122][2],1,,,,.T.,)

	oCoSiaf  := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[123][1], aValoresN[123][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[123][2],1,,,,.T.,)

	oEndNo   := TComboBox():New( 210, 200, {|u|if(PCount()>0,aValoresN[124][1]:=u,aValoresN[124][1])}, aNaoSim, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[124][1], aValoresN[124][2], 1, , )
	selecionaNaoSim(oEndNo, SA2->A2_ENDNOT)

	oMotNif  := TComboBox():New( 240, 200, {|u|if(PCount()>0,aValoresN[125][1]:=u,aValoresN[125][1])}, aMotNif, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[125][1], aValoresN[125][2], 1, , )
	selecionaVal(oMotnif, SA2->A2_MOTNIF, aMotNif)

	oCliLoj  := TComboBox():New( 270, 200, {|u|if(PCount()>0,aValoresN[126][1]:=u,aValoresN[126][1])}, aClientes, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[126][1], aValoresN[126][2], 1, , )
	selecionaVal(oCliLoj, SA2->A2_LOJCLI, aClientes)

	oClasPj  := TComboBox():New( 300, 200, {|u|if(PCount()>0,aValoresN[127][1]:=u,aValoresN[127][1])}, aClasPj, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[127][1], aValoresN[127][2], 1, , )
	selecionaVal(oClasPj, SA2->A2_TPENT, aClasPj)

	oCargo   := TGet():New( 030, 300, {|u| if(PCount()==0, aValoresN[128][1], aValoresN[128][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,,,,,,.T.,.F.,, aValoresN[128][2],1,,,,.T.,)

	oConf    := TComboBox():New( 000, 300, {|u|if(PCount()>0,aValoresN[129][1]:=u,aValoresN[129][1])}, aConf, 100, , oTFolder:aDialogs[9], ,, , , , .T., ,, , , , , , , aValoresN[129][1], aValoresN[129][2], 1, , )
	selecionaVal(oConf, SA2->A2_CONFFIS, aConf)


	oButton3   := TButton():Create(oJanela,340,1,"Atualizar",{||updateDb(SA2->(RecNo()),aValores, aValoresN, oJanela)},75,20,,,,.T.,,,,,,)

	oJanela:Activate(,,,.T.,,,)



RETURN


Static Function updateDb(recno, aValores, aValoresN, oJanela)
	Local aValoresFaltantes := verificaValores(aValores)
	Local cValoresTexto := ''
	Local cQryUpd
	Local nI
	If Len(aValoresFaltantes) > 0
		For nI := 1 To Len(aValoresFaltantes)
			cValoresTexto += aValoresFaltantes[nI]
			cValoresTexto += ' '
			cValoresTexto += Chr(13)+Chr(10)
		Next
		FWAlertError("Os seguintes valores não podem estar vazios:" + Chr(13)+Chr(10) + cValoresTexto ,"Erro na atualização")
		RETURN
	Endif


	cQryUpd := "UPDATE " + RetSqlName("SA2") + " "
	cQryUpd += "SET a2_cod = '" + aValores[1][1] + "', "
	cQryUpd += "a2_loja = '" + aValores[2][1] + "', "
	cQryUpd += "a2_nome = '" + AllTrim(aValores[3][1]) + "', "
	cQryUpd += "a2_nreduz = '" + aValores[7][1] + "', "
	cQryUpd += "a2_end = '" + AllTrim(aValores[6][1]) + "', "
	cQryUpd += "a2_est = '" + AllTrim(getSiglaEst(aValores[4][1])) + "', "
	cQryUpd += "a2_mun = '" + AllTrim(aValores[5][1]) + "', "
	cQryUpd += "a2_tipo = '" + Left(aValores[8][1], 1) + "', "
	cQryUpd += "a2_cgc = '" + aValoresN[1][1] + "', "
	cQryUpd += "a2_cod_mun = '" + trataCodMun(aValoresN[2][1]) + "', "
	cQryUpd += "a2_tel = '" + aValoresN[3][1] + "', "
	cQryUpd += "a2_pfisica = '" + aValoresN[4][1] + "', "
	cQryUpd += "a2_inscr = '" + aValoresN[5][1] + "', "
	cQryUpd += "a2_inscrm = '" + aValoresN[6][1] + "', "
	cQryUpd += "a2_ddi = '" + aValoresN[7][1] + "', "
	cQryUpd += "a2_ddd = '" + aValoresN[9][1] + "', "
	cQryUpd += "a2_pais = '" + trataCodMun(aValoresN[8][1]) + "', "
	cQryUpd += "a2_depto = '" + aValoresN[11][1] + "', "
	cQryUpd += "a2_email = '" + aValoresN[12][1] + "', "
	cQryUpd += "a2_hpage = '" + aValoresN[13][1] + "', "
	cQryUpd += "a2_telex = '" + aValoresN[14][1] + "', "
	cQryUpd += "a2_endcomp = '" + aValoresN[15][1] + "', "
	cQryUpd += "a2_msblql = '" + Left(aValoresN[16][1],1) + "', "
	cQryUpd += "a2_complem = '" + aValoresN[17][1] + "', "
	cQryUpd += "a2_fornema = '" + Left(aValoresN[18][1],1) + "', "
	cQryUpd += "a2_cbo = '" + aValoresN[19][1] + "', "
	cQryUpd += "a2_cnae = '" + aValoresN[20][1] + "', "
	cQryUpd += "A2_BANCO = '" + aValoresN[21][1] + "', "
	cQryUpd += "A2_AGENCIA = '" + aValoresN[22][1] + "', "
	cQryUpd += "A2_NUMCON = '" + aValoresN[23][1] + "', "
	cQryUpd += "A2_NATUREZ = '" + aValoresN[24][1] + "', "
	cQryUpd += "A2_COND = '" + aValoresN[25][1] + "', "
	cQryUpd += "A2_CODADM = '" + aValoresN[26][1] + "', "
	cQryUpd += "A2_FORMPAG = '" + trataFormaPag(aValoresN[27][1]) + "', "
	cQryUpd += "A2_DVCTA = '" + aValoresN[28][1] + "', "
	cQryUpd += "A2_DVAGE = '" + aValoresN[29][1] + "', "
	cQryUpd += "A2_TIPORUR = '" + Left(aValoresN[30][1],1) + "', "
	cQryUpd += "A2_RECISS = '" + Left(aValoresN[31][1],1) + "', "
	cQryUpd += "A2_CODMUN = '" + trataCodZf(aValoresN[32][1]) + "', "
	cQryUpd += "A2_RECINSS = '" + Left(aValoresN[33][1],2) + "', "
	cQryUpd += "A2_TPESSOA = '" + Left(aValoresN[34][1],2) + "', "
	cQryUpd += "A2_CODPAIS = '" + trataCodMun(aValoresN[35][1]) + "', "
	cQryUpd += "A2_TPISSRS = '" + aValoresN[36][1] + "', "
	cQryUpd += "A2_GRPTRIB = '" + aValoresN[37][1] + "', "
	cQryUpd += "A2_RECPIS = '" + Left(aValoresN[38][1],1) + "', "
	cQryUpd += "A2_RECCSLL = '" + Left(aValoresN[39][1],1) + "', "
	cQryUpd += "A2_RECCOFI = '" + Left(aValoresN[40][1],1) + "', "
	cQryUpd += "A2_CALCIRF = '" + Left(aValoresN[41][1],1) + "', "
	cQryUpd += "A2_VINCULO = '" + aValoresN[42][1] + "', "
	cQryUpd += "A2_DTINIV = '" + DtoS(aValoresN[43][1]) + "', "
	cQryUpd += "A2_DTFIMV = '" + DToS(aValoresN[44][1]) + "', "
	cQryUpd += "A2_RFACS = '" + Left(aValoresN[45][1],1) + "', "
	cQryUpd += "A2_CONTRIB = '" + Left(aValoresN[46][1],1) + "', "
	cQryUpd += "A2_RFABOV = '" + Left(aValoresN[47][1],1) + "', "
	cQryUpd += "A2_DEDBSPC = '" + Left(aValoresN[48][1],1) + "', "
	cQryUpd += "A2_RECFMD = '" + Left(aValoresN[49][1],1) + "', "
	cQryUpd += "A2_CPOMSP = '" + Left(aValoresN[50][1],1) + "', "
	cQryUpd += "A2_SITESBH = '" + Left(aValoresN[51][1],1) + "', "
	cQryUpd += "A2_TPLOGR = '" + aValoresN[52][1] + "', "
	cQryUpd += "A2_TPJ = '" + Left(aValoresN[53][1],1) + "', "
	cQryUpd += "A2_DTCONV = '" + DtoS(aValoresN[54][1]) + "', "
	cQryUpd += "A2_CTARE = '" + Left(aValoresN[55][1],1) + "', "
	cQryUpd += "A2_RECFET = '" + Left(aValoresN[56][1],1) + "', "
	cQryUpd += "A2_INCLTMG = '" + Left(aValoresN[58][1],1) + "', "
	cQryUpd += "A2_FOMEZER = '" + Left(aValoresN[59][1],1) + "', "
	cQryUpd += "A2_IRPROG = '" + Left(aValoresN[60][1],1) + "', "
	cQryUpd += "A2_INOVAUT = '" + Left(aValoresN[61][1],1) + "', "
	cQryUpd += "A2_NOMRESP = '" + aValoresN[62][1] + "', "
	cQryUpd += "A2_CONTATO = '" + aValoresN[63][1] + "', "
	cQryUpd += "A2_TRANSP = '" + aValoresN[64][1] + "', "
	cQryUpd += "A2_CIVIL = '" + Left(aValoresN[67][1],1) + "', "
	cQryUpd += "A2_RECSEST = '" + Left(aValoresN[68][1],1) + "', "
	cQryUpd += "A2_PAISSUB = '" + aValoresN[69][1] + "', "
	cQryUpd += "A2_TPCON = '" + aValoresN[70][1] + "', "
	cQryUpd += "A2_NIFEX = '" + aValoresN[71][1] + "', "
	cQryUpd += "A2_DTFIMR = '" + DToS(aValoresN[72][1]) + "', "
	cQryUpd += "A2_DTINIR = '" + DToS(aValoresN[73][1]) + "',  "
	cQryUpd += "A2_CODNIT = '" + aValoresN[83][1] + "',  "
	cQryUpd += "A2_DTNASC = '" + DToS(aValoresN[84][1]) + "',  "
	cQryUpd += "A2_CATEG = '" + aValoresN[85][1] + "',  "
	cQryUpd += "A2_OCORREN = '" + aValoresN[86][1] + "',  "
	cQryUpd += "A2_CATEFD = '" + aValoresN[87][1] + "',  "
	cQryUpd += "A2_PRIOR = '" + aValoresN[88][1] + "',  "
	cQryUpd += "A2_ID_FBFN = '" + Left(aValoresN[89][1],1) + "',  "
	cQryUpd += "A2_REPRES = '" + aValoresN[90][1] + "',  "
	cQryUpd += "A2_ID_REPR = '" + Left(aValoresN[91][1],1) + "',  "
	cQryUpd += "A2_FABRICA = '" + Left(aValoresN[92][1],1) + "',  "
	cQryUpd += "A2_CODLOC = '" + aValoresN[93][1] + "',  "
	cQryUpd += "A2_RECCIDE = '" + Left(aValoresN[95][1],1) + "',  "
	cQryUpd += "A2_CODBLO = '" + aValoresN[96][1] + "',   "
	cQryUpd += "A2_INDRUR = '" + Left(aValoresN[97][1],1) + "',   "
	cQryUpd += "A2_ISSRSLC = '" + Left(aValoresN[99][1],1) + "',   "
	cQryUpd += "A2_RFASEMT = '" + Left(aValoresN[100][1],1) + "',   "
	cQryUpd += "A2_CCICMS = '" + Left(aValoresN[101][1],1) + "',   "
	cQryUpd += "A2_RIMAMT = '" + Left(aValoresN[102][1],1) + "',   "
	cQryUpd += "A2_CODFI = '" + aValoresN[103][1] + "',   "
	cQryUpd += "A2_REGESIM = '" + Left(aValoresN[104][1],1) + "',   "
	cQryUpd += "A2_CPRB = '" + Left(aValoresN[105][1],1) + "',    "
	cQryUpd += "A2_INDCP = '" + Left(aValoresN[106][1],1) + "',    "
	cQryUpd += "A2_INCULT = '" + Left(aValoresN[108][1],1) + "',    "
	cQryUpd += "A2_DESPORT = '" + Left(aValoresN[109][1],1) + "',    "
	cQryUpd += "A2_CALCINP = '" + Left(aValoresN[110][1],1) + "',    "
	cQryUpd += "A2_IMPIP = '" + Left(aValoresN[111][1],1) + "',    "
	cQryUpd += "A2_CLIENTE = '" + aValoresN[112][1] + "',    "
	cQryUpd += "A2_SIMPNAC = '" + Left(aValoresN[113][1],1) + "',   "
	cQryUpd += "A2_RFUNDES = '" + Left(aValoresN[115][1],1) + "',   "
	cQryUpd += "A2_PRSTSER = '" + aValoresN[116][1] + "',   "
	cQryUpd += "A2_MJURIDI = '" + Left(aValoresN[117][1],1) + "',   "
	cQryUpd += "A2_MUNSC = '" + aValoresN[118][1] + "',   "
	cQryUpd += "A2_TRIBFAV = '" + Left(aValoresN[120][1],1) + "',   "
	cQryUpd += "A2_MSBLQD = '" + DtoS(aValoresN[122][1]) + "',   "
	cQryUpd += "A2_CODSIAF = '" + aValoresN[123][1] + "',   "
	cQryUpd += "A2_ENDNOT = '" + Left(aValoresN[124][1],1) + "',   "
	cQryUpd += "A2_MOTNIF = '" + Left(aValoresN[125][1],1) + "',   "
	cQryUpd += "A2_LOJCLI = '" + Left(aValoresN[126][1],1) + "',   "
	cQryUpd += "A2_TPENT = '" + Left(aValoresN[127][1],1) + "',   "
	cQryUpd += "A2_CARGO = '" + aValoresN[128][1] + "',   "
	cQryUpd += "A2_CONFFIS = '" + Left(aValoresN[129][1],1) + "'   "
	cQryUpd += "WHERE R_E_C_N_O_ = '" + cValToChar(recno) + "' "
	cQryUpd += "AND D_E_L_E_T_ = ' '"

	nErro := TcSqlExec(cQryUpd)

	If nErro != 0
		msgStop("Erro.")
	Endif


	FWAlertSuccess("Atualizado com sucesso", "Atualizado")
	oJanela:end()
RETURN


Static Function delete()
	Local oJanela  := TDialog():New(0, 0, 100, 300,'Delete de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	Local oButton1
	Local oButton2

	oButton2 	  :=TButton():Create(oJanela,30,10,"Apagar",{||deleteDb(SA2->(RecNo()), oJanela)},55,20,,,,.T.,,,,,,)
	oButton1      := TButton():Create(oJanela,30,90,"Cancelar",{||oJanela:end()},55,20,,,,.T.,,,,,,)


	oJanela:Activate(,,,.T.,,,)


RETURN


Static Function deleteDb(recno, oJanela)

	Local cQryUpd
	cQryUpd := "UPDATE " + RetSqlName("SA2") + " "
	cQryUpd += "SET D_E_L_E_T_ = '" + "*" + "', "
	cQryUpd += "R_E_C_D_E_L_ = '" + cValToChar(recno) + "'"
	cQryUpd += "WHERE R_E_C_N_O_ = '" + cValToChar(recno) + "' "
	cQryUpd += "AND D_E_L_E_T_ = ' '"

	nErro := TcSqlExec(cQryUpd)

	If nErro != 0

		msgStop("Erro.")

	Endif

	oJanela:end()
	oBrowse:refresh()

RETURN


Static Function view()
	Local oJanela  := TDialog():New(0, 0, 730, 1100, 'Cadastro de fornecedores', , , , , CLR_BLACK, CLR_WHITE, , , .T.)
	Local nNumero := 0

	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }
	Local aEstados := FWGetSX5("12")
	Local aEstadosSiglas := {}
	Local aValores := { ;
		{SA2->A2_COD, 'Código'}, ;
		{SA2->A2_LOJA, 'Loja'}, ;
		{SA2->A2_NOME, 'Razão Social'}, ;
		{SA2->A2_EST, 'Estado'}, ;
		{SA2->A2_MUN, 'Municipio'}, ;
		{SA2->A2_END, 'Endereço'}, ;
		{SA2->A2_NREDUZ, 'Nome Fantasia'}, ;
		{SA2->A2_TIPO, 'Tipo'} ;
		}
	Local aValoresN := { ;
		{SA2->A2_CGC, 'CPF/CNPJ'}, ;
		{'', 'Código Município'}, ;
		{SA2->A2_TEL, 'Telefone'}, ;
		{SA2->A2_PFISICA, 'RG/Ced.Estr.'}, ;
		{SA2->A2_INSCR, 'Ins. Estad.'}, ;
		{SA2->A2_INSCRM, 'Ins. Municip.'}, ;
		{SA2->A2_DDI, 'DDI'}, ;
		{SA2->A2_PAIS, 'País'}, ;
		{SA2->A2_DDD, 'DDD'}, ;
		{'', 'Descr. País'}, ;
		{SA2->A2_DEPTO, 'Departamento'}, ;
		{SA2->A2_EMAIL, 'Email'}, ;
		{SA2->A2_HPAGE, 'Homepage'}, ;
		{A2_TELEX, 'TELEX'}, ;
		{SA2->A2_ENDCOMP, 'END. COMPLEMENTAR'}, ;
		{SA2->A2_MSBLQL, 'Bloqueado'}, ;
		{SA2->A2_COMPLEM, 'Complemento'}, ;
		{SA2->A2_FORNEMA, 'Forn.Mailing'}, ;
		{SA2->A2_CBO, 'Cod CBO'}, ;
		{SA2->A2_CNAE, 'Cod CNAE'}, ;
		{SA2->A2_BANCO, 'Banco'}, ;
		{SA2->A2_AGENCIA, 'Cod. Agência'}, ;
		{SA2->A2_NUMCON, 'Cta Corrente'}, ;
		{SA2->A2_NATUREZ, 'Natureza'}, ;
		{SA2->A2_COND, 'Cond. Pagto'}, ;
		{SA2->A2_CODADM, 'CodAdm'}, ;
		{SA2->A2_FORMPAG, 'Forma de pagamento'}, ;
		{SA2->A2_DVCTA, 'Dv Cta Cnab'}, ;
		{SA2->A2_DVAGE, 'DV Age Cnab'}, ;
		{SA2->A2_TIPORUR, 'Tp.Contr.Soc'}, ;
		{SA2->A2_RECISS, 'Recolhe ISS'}, ;
		{SA2->A2_CODMUN, 'Cod. Mun. ZF'}, ;
		{SA2->A2_RECINSS, 'Calc. INSS'}, ;
		{SA2->A2_TPESSOA, 'Tipo Pessoa'}, ;
		{SA2->A2_CODPAIS, 'País Bacen'}, ;
		{SA2->A2_TPISSRS, 'Tipo Escr.'}, ;
		{SA2->A2_GRPTRIB, 'Grp. Tribut.'}, ;
		{SA2->A2_RECPIS, 'Rec. PIS'}, ;
		{SA2->A2_RECCSLL, 'Rec.CSLL'}, ;
		{SA2->A2_RECCOFI, 'Rec.COFINS'}, ;
		{SA2->A2_CALCIRF, 'CÁLC. IRRF'}, ;
		{SA2->A2_VINCULO, 'P. VINCULO'}, ;
		{A2_DTINIV, 'DT INI VINCU'}, ;
		{A2_DTFIMV, 'DT FIM VINCU'}, ;
		{SA2->A2_RFACS, 'REC. FACS'}, ;
		{SA2->A2_CONTRIB, 'Contribuinte'}, ;
		{SA2->A2_RFABOV, 'REC. FABOV'}, ;
		{SA2->A2_DEDBSPC, 'DED. PIS/COF'}, ;
		{SA2->A2_RECFMD, 'REC. FAMAD'}, ;
		{SA2->A2_CPOMSP, 'REG. CPOM'}, ;
		{SA2->A2_SITESBH, 'SITESPRES BH'}, ;
		{SA2->A2_TPLOGR, 'TP. LOGRAD'}, ;
		{SA2->A2_TPJ, 'TPJ'}, ;
		{SA2->A2_DTCONV, 'Dt. Conv'}, ;
		{SA2->A2_CTARE, 'Contr TARE?'}, ;
		{SA2->A2_RECFET, 'Rec. FETHAB'}, ;
		{SA2->A2_MINIRF, 'Vlr. Min. IR'}, ;
		{SA2->A2_INCLTMG, 'Inc.Prd.Leit'}, ;
		{SA2->A2_FOMEZER, 'Fome Zero'}, ;
		{SA2->A2_IRPROG, 'IRRF Prog'}, ;
		{SA2->A2_INOVAUT, 'Inovar Auto'}, ;
		{SA2->A2_NOMRESP, 'Nome Resp.'}, ;
		{SA2->A2_CONTATO, 'Contato'}, ;
		{SA2->A2_TRANSP, 'Transp.'}, ;
		{'', '1a Compra'}, ;
		{'', 'Ult Compra'}, ;
		{SA2->A2_CIVIL, 'Estado Civil'}, ;
		{SA2->A2_RECSEST, 'Recolhe SEST'},  ;
		{SA2->A2_PAISSUB, 'SubDivPais'},  ;
		{SA2->A2_TPCON, 'Tipo Contrat'},  ;
		{SA2->A2_NIFEX, 'Codigo NIF'},  ;
		{SA2->A2_DTFIMR, 'Data Fim'},  ;
		{SA2->A2_DTINIR, 'Data Inicio'}, ;
		{'', 'Benef. Rend.'},  ;
		{'', 'Est./Prov.'},  ;
		{'', 'Forma Trib'},  ;
		{'', 'Logradouro'},  ;
		{'', 'Complemento'},  ;
		{'', 'Bairro/Dist.'},  ;
		{'', 'Rendimento'},  ;
		{'', 'Cidade'},  ;
		{'', 'CNPJ Empr.Ex'},  ;
		{SA2->A2_CODNIT, 'Num Insc Aut'},  ;
		{SA2->A2_DTNASC, 'Data nasc.'},  ;
		{SA2->A2_CATEG, 'Categ. SEFIP'},  ;
		{SA2->A2_OCORREN, 'Ocorrência'},  ;
		{SA2->A2_CATEFD, 'Cat eSocial'},  ;
		{SA2->A2_PRIOR, 'Prioridade'},  ;
		{SA2->A2_ID_FBFN, 'Identificac.'},  ;
		{SA2->A2_REPRES, 'Represent.'}, ;
		{SA2->A2_ID_REPR, 'Identif.Repr.'}, ;
		{SA2->A2_FABRICA, 'Fabricante'}, ;
		{SA2->A2_CODLOC, 'Cod.Local'},  ;
		{'', 'Maior Nota'},  ;
		{SA2->A2_RECCIDE, 'Rec Cide'},  ;
		{SA2->A2_CODBLO, 'Cod.Bloqueio'},  ;
		{SA2->A2_INDRUR,'Ind. Prod. Rur'}, ;
		{'','UF Ficticia'}, ;
		{SA2->A2_ISSRSLC,'LC ISS RS'}, ;
		{SA2->A2_RFASEMT,'Rec.FASE-MT'}, ;
		{SA2->A2_CCICMS,'CCICMS'}, ;
		{SA2->A2_RIMAMT,'Rec. IMA-MT'}, ;
		{SA2->A2_CODFI,'Cod. FIESP'}, ;
		{SA2->A2_REGESIM,'Rg. Simp. MT'}, ;
		{SA2->A2_CPRB,'Ret. CPRB'}, ;
		{SA2->A2_INDCP, 'Ind. Rural'}, ;
		{'', 'Ident.Exp.'}, ;
		{SA2->A2_INCULT, 'Inc. Cultura'}, ;
		{SA2->A2_DESPORT, 'Assoc. Desp.'}, ;
		{SA2->A2_CALCINP, 'Calc.INSS.Pt'}, ;
		{SA2->A2_IMPIP, 'Ident.Prod.'}, ;
		{SA2->A2_CLIENTE, 'Cód. Cliente'}, ;
		{SA2->A2_SIMPNAC, 'Opt Simp Nac'}, ;
		{'', 'Cód Func'}, ;
		{SA2->A2_RFUNDES,'Rec.FUNDESA'}, ;
		{SA2->A2_PRSTSER,'Ind. Prest.'}, ;
		{SA2->A2_MJURIDI,'M.Jurídico'}, ;
		{SA2->A2_MUNSC,'Cod Mun SC'},;
		{'','CPF Rural'}, ;
		{SA2->A2_TRIBFAV,'Pes.Tri.Fav'}, ;
		{'','Fil. Transf.'}, ;
		{SA2->A2_MSBLQD,'BlqTemporal'}, ;
		{SA2->A2_CODSIAF,'Cod.Mun.SIAF'}, ;
		{SA2->A2_ENDNOT,'End.Not.Form'}, ;
		{SA2->A2_MOTNIF, 'Mot.NIF'},;
		{SA2->A2_LOJCLI, 'Loja Cliente'},;
		{SA2->A2_TPENT, 'Clas.PJ'},;
		{SA2->A2_CARGO, 'Cargo Resp.'},;
		{SA2->A2_CONFFIS, 'Conf. Física'};
		}

	Local aEstados2 := {}
	Local aPaises := trataPaises()
	Local oLoja
	Local oCodigo
	Local oTelefone
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oRazaoSocial
	Local OPFisica
	Local oInscr
	Local oDdi
	Local oDdd
	Local oTFolder := TFolder():New(0, 0, aTFolder, , oJanela, , , , .T., , 551, 730)

	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next

	For nNumero := 1 to 26
		AADD(aEstadosSiglas, AllTrim(aEstados[nNumero][3]))
	next

	/////////////////////// ABA 'Cadastrais' ///////////////////////
	aValoresN[2][1] := getNomeMun(SA2->A2_COD_MUN, aValores[4][1])
	aValoresN[10][1] := getPaisFromCod(A2_PAIS)
	oCodigo       := TGet():New( 000, 001, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oCGC		  := TGet():New( 000, 100, {|u|if(PCount()==0,aValoresN[1][1],aValoresN[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 999.999.999-99",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[1][1],,,,,,,aValoresN[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 020, 001, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oCodMun		  := TGet():New( 020, 100, {|u|if(PCount()==0,aValoresN[2][1],aValoresN[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[2][1],,,,,,,aValoresN[2][2],1,,,,.T.,)

	oNFantasia    := TGet():New( 040, 001, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oTelefone     := TGet():New( 040, 100, {|u|if(PCount()==0,aValoresN[3][1],aValoresN[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 9999-9999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[3][1],,,,,,,aValoresN[3][2],1,,,,.T.,)

	oEstado       := TGet():New( 060, 001, {|u|if(PCount()==0,aValores[4][1],aValores[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[4][1],,,,,,,aValores[4][2],1,,,,.T.,)

	OPFisica 	  := TGet():New( 060, 100, {|u|if(PCount()==0,aValoresN[4][1],aValoresN[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[4][1],,,,,,,aValoresN[4][2],1,,,,.T.,)

	oMunicipio    := TGet():New( 085, 001, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oInscr 		  := TGet():New( 085, 100, {|u|if(PCount()==0,aValoresN[5][1],aValoresN[5][1]:=u)},oTFolder:aDialogs[1], 096, 009, "@N 99999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[5][1],,,,,,,aValoresN[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 001, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oInscrM 	  := TGet():New( 105, 100, {|u|if(PCount()==0,aValoresN[6][1],aValoresN[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[6][1],,,,,,,aValoresN[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 001, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)

	oDdi          := TGet():New( 125, 100, {|u|if(PCount()==0,aValoresN[7][1],aValoresN[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[7][1],,,,,,,aValoresN[7][2],1,,,,.T.,)

	oTipo 		  := TGet():New( 150, 001, {|u|if(PCount()==0,aValores[8][1],aValores[8][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[8][1],,,,,,,aValores[8][2],1,,,,.T.,)

	oDdd          := TGet():New( 150, 100, {|u|if(PCount()==0,aValoresN[9][1],aValoresN[9][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[9][1],,,,,,,aValoresN[9][2],1,,,,.T.,)

	oDescPais	  := TGet():New( 200, 100, {|u|if(PCount()==0,aValoresN[10][1],aValoresN[10][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[10][1],,,,,,,aValoresN[10][2],1,,,,.T.,)

	oPais 		  := TGet():New( 170, 100, {|u|if(PCount()==0,aValoresN[8][1],aValoresN[8][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[8][1],,,,,,,aValoresN[8][2],1,,,,.T.,)
	selecionaPais(@oPais,SA2->A2_PAIS,aPaises)

	oDept 		  := TGet():New( 000, 200, {|u| if(PCount()==0, aValoresN[11][1], aValoresN[11][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[11][1],,,,,,, aValoresN[11][2],1,,,,.T.,)

	oEmail 		  := TGet():New( 020, 200, {|u| if(PCount()==0, aValoresN[12][1], aValoresN[12][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[12][1],,,,,,, aValoresN[12][2],1,,,,.T.,)

	oHpage 		  := TGet():New( 040, 200, {|u| if(PCount()==0, aValoresN[13][1], aValoresN[13][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[13][1],,,,,,, aValoresN[13][2],1,,,,.T.,)

	oTelex 		  := TGet():New( 060, 200, {|u| if(PCount()==0, aValoresN[14][1], aValoresN[14][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[14][1],,,,,,, aValoresN[14][2],1,,,,.T.,)

	oEndcomp 	  := TGet():New( 080, 200, {|u| if(PCount()==0, aValoresN[15][1], aValoresN[15][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[15][1],,,,,,, aValoresN[15][2],1,,,,.T.,)

	oBloq         := TGet():New( 100, 200, {|u| if(PCount()==0, aValoresN[16][1], aValoresN[16][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[16][1],,,,,,, aValoresN[16][2],1,,,,.T.,)

	oComplekm     := TGet():New( 120, 200, {|u| if(PCount()==0, aValoresN[17][1], aValoresN[17][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[17][1],,,,,,, aValoresN[17][2],1,,,,.T.,)

	oForm         := TGet():New( 140, 200, {|u| if(PCount()==0, aValoresN[18][1], aValoresN[18][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[18][1],,,,,,, aValoresN[18][2],1,,,,.T.,)

	oCbo		  := TGet():New( 160, 200, {|u| if(PCount()==0, aValoresN[19][1], aValoresN[19][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[19][1],,,,,,, aValoresN[19][2],1,,,,.T.,)

	oCnae 		  := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[20][1], aValoresN[20][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999-9/9999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[20][1],,,,,,, aValoresN[20][2],1,,,,.T.,)



	/////////////////////// ABA 'Adm/Fin.' ///////////////////////

	oBanco		  := TGet():New( 000, 001, {|u|if(PCount()==0,aValoresN[21][1],aValoresN[21][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[21][1],,,,,,,aValoresN[21][2],1,,,,.T.,)

	oCodAgencia	  := TGet():New( 020, 001, {|u|if(PCount()==0,aValoresN[22][1],aValoresN[22][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[22][1],,,,,,,aValoresN[22][2],1,,,,.T.,)

	oCtCorrente	  := TGet():New( 040, 001, {|u|if(PCount()==0,aValoresN[23][1],aValoresN[23][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[23][1],,,,,,,aValoresN[23][2],1,,,,.T.,)

	oNatureza     := TGet():New( 060, 001, {|u|if(PCount()==0,aValoresN[24][1],aValoresN[24][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[24][1],,,,,,,aValoresN[24][2],1,,,,.T.,)

	oCondominio   := TGet():New( 080, 001, {|u|if(PCount()==0,aValoresN[25][1],aValoresN[25][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[25][1],,,,,,,aValoresN[25][2],1,,,,.T.,)

	oCodAdm		  := TGet():New( 100, 001, {|u|if(PCount()==0,aValoresN[26][1],aValoresN[26][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[26][1],,,,,,,aValoresN[26][2],1,,,,.T.,)

	oFormPagto	  := TGet():New( 120, 001, {|u|if(PCount()==0,aValoresN[27][1],aValoresN[27][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E XXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[27][1],,,,,,,aValoresN[27][2],1,,,,.T.,)

	oDvcta        := TGet():New( 140, 001, {|u| if(PCount()==0, aValoresN[28][1], aValoresN[28][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@N 99", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[28][1],,,,,,, aValoresN[28][2],1,,,,.T.,)

	oDvAg         := TGet():New( 160, 001, {|u| if(PCount()==0, aValoresN[29][1], aValoresN[29][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@E X", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[29][1],,,,,,, aValoresN[29][2],1,,,,.T.,)

	/////////////////////// ABA 'Fiscais' ///////////////////////

	oTipoContr	  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[30][1], aValoresN[30][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[30][1],,,,,,, aValoresN[30][2],1,,,,.T.,)

	oRecIss		  := TGet():New( 020, 001, {|u| if(PCount()==0, aValoresN[31][1], aValoresN[31][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[31][1],,,,,,, aValoresN[31][2],1,,,,.T.,)

	oCodMunZf	  := TGet():New( 040, 001, {|u| if(PCount()==0, aValoresN[32][1], aValoresN[32][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[32][1],,,,,,, aValoresN[32][2],1,,,,.T.,)

	oCalcInss 	  := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[33][1], aValoresN[33][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[33][1],,,,,,, aValoresN[33][2],1,,,,.T.,)

	oTPessoa	  := TGet():New( 080, 001, {|u| if(PCount()==0, aValoresN[34][1], aValoresN[34][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[34][1],,,,,,, aValoresN[34][2],1,,,,.T.,)

	oPaisBacen    := TGet():New( 100, 001, {|u| if(PCount()==0, aValoresN[35][1], aValoresN[35][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[35][1],,,,,,, aValoresN[35][2],1,,,,.T.,)

	oTipoEscr	  := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[36][1], aValoresN[36][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[36][1],,,,,,, aValoresN[36][2],1,,,,.T.,)

	oGrpTrib 	  := TGet():New( 140, 001, {|u| if(PCount()==0, aValoresN[37][1], aValoresN[37][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[37][1],,,,,,, aValoresN[37][2],1,,,,.T.,)

	oRecPis	  	  := TGet():New( 160, 001, {|u| if(PCount()==0, aValoresN[38][1], aValoresN[38][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[38][1],,,,,,, aValoresN[38][2],1,,,,.T.,)

	oRecCSLL	  := TGet():New( 180, 001, {|u| if(PCount()==0, aValoresN[39][1], aValoresN[39][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[39][1],,,,,,, aValoresN[39][2],1,,,,.T.,)

	oRecCofins	  := TGet():New( 200, 001, {|u| if(PCount()==0, aValoresN[40][1], aValoresN[40][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[40][1],,,,,,, aValoresN[40][2],1,,,,.T.,)

	oCalcIRRF 	  := TGet():New( 000, 100, {|u| if(PCount()==0, aValoresN[41][1], aValoresN[41][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[41][1],,,,,,, aValoresN[41][2],1,,,,.T.,)

	oPVinculo     := TGet():New( 030, 100, {|u| if(PCount()==0, aValoresN[42][1], aValoresN[42][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[42][1],,,,,,, aValoresN[42][2],1,,,,.T.,)

	oDtIniV       := TGet():New( 060, 100, {|u| if(PCount()==0, aValoresN[43][1], aValoresN[43][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[43][2],1,,,,.T.,)

	oDtFimV       := TGet():New( 090, 100, {|u| if(PCount()==0, aValoresN[44][1], aValoresN[44][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[44][2],1,,,,.T.,)

	oRecFacs      := TGet():New( 120, 100, {|u| if(PCount()==0, aValoresN[45][1], aValoresN[45][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[45][1],,,,,,, aValoresN[45][2],1,,,,.T.,)

	oContrib      := TGet():New( 150, 100, {|u| if(PCount()==0, aValoresN[46][1], aValoresN[46][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[46][1],,,,,,, aValoresN[46][2],1,,,,.T.,)

	oRecFabov     := TGet():New( 180, 100, {|u| if(PCount()==0, aValoresN[47][1], aValoresN[47][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[47][1],,,,,,, aValoresN[47][2],1,,,,.T.,)

	oDedPis       := TGet():New( 210, 100, {|u| if(PCount()==0, aValoresN[48][1], aValoresN[48][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[48][1],,,,,,, aValoresN[48][2],1,,,,.T.,)

	oRecFmd       := TGet():New( 240, 100, {|u| if(PCount()==0, aValoresN[49][1], aValoresN[49][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[49][1],,,,,,, aValoresN[49][2],1,,,,.T.,)

	oRecCpom      := TGet():New( 270, 100, {|u| if(PCount()==0, aValoresN[50][1], aValoresN[50][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[50][1],,,,,,, aValoresN[50][2],1,,,,.T.,)

	oSitEspRes    := TGet():New( 300, 100, {|u| if(PCount()==0, aValoresN[51][1], aValoresN[51][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[51][1],,,,,,, aValoresN[51][2],1,,,,.T.,)

	oTpLograd 	  := TGet():New( 000, 200, {|u| if(PCount()==0, aValoresN[52][1], aValoresN[52][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[52][1],,,,,,, aValoresN[52][2],1,,,,.T.,)

	oTpj          := TGet():New( 030, 200, {|u| if(PCount()==0, aValoresN[53][1], aValoresN[53][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[53][1],,,,,,, aValoresN[53][2],1,,,,.T.,)

	oDtConv       := TGet():New( 060, 200, {|u| if(PCount()==0, aValoresN[54][1], aValoresN[54][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[54][2],1,,,,.T.,)

	oCTare        := TGet():New( 090, 200, {|u| if(PCount()==0, aValoresN[55][1], aValoresN[55][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[55][2],1,,,,.T.,)

	oRecFet       := TGet():New( 120, 200, {|u| if(PCount()==0, aValoresN[56][1], aValoresN[56][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[56][2],1,,,,.T.,)

	oVlrMinIr     := TGet():New( 150, 200, {|u| if(PCount()==0, aValoresN[57][1], aValoresN[57][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[57][2],1,,,,.T.,)

	oIncPdrLei    := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[58][1], aValoresN[58][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[58][2],1,,,,.T.,)

	oFomeZer      := TGet():New( 210, 200, {|u| if(PCount()==0, aValoresN[59][1], aValoresN[59][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[59][2],1,,,,.T.,)

	oIRProg       := TGet():New( 240, 200, {|u| if(PCount()==0, aValoresN[60][1], aValoresN[60][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[60][2],1,,,,.T.,)

	oInovaut      := TGet():New( 270, 200, {|u| if(PCount()==0, aValoresN[61][1], aValoresN[61][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[61][2],1,,,,.T.,)

	oNomResp      := TGet():New( 300, 200, {|u| if(PCount()==0, aValoresN[62][1], aValoresN[62][1]:=u)}, oTFolder:aDialogs[3], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[62][2],1,,,,.T.,)

	/////////////////////// ABA '4' ///////////////////////

	oContato   	  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[63][1], aValoresN[63][1]:=u)}, oTFolder:aDialogs[4], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[63][2],1,,,,.T.,)

	oTransp    	  := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[64][1], aValoresN[64][1]:=u)}, oTFolder:aDialogs[4], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[64][2],1,,,,.T.,)

	/////////////////////// ABA 'Compras' ///////////////////////

	oCivil        := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[67][1], aValoresN[67][1]:=u)}, oTFolder:aDialogs[5], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[67][2],1,,,,.T.,)

	/////////////////////// ABA 'TMS' ///////////////////////

	oSest    := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[68][1], aValoresN[68][1]:=u)}, oTFolder:aDialogs[6], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[68][2],1,,,,.T.,)

	///////////////////////// ABA 'Residente Exterior' ///////////////////////

	oSubDiv  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[69][1], aValoresN[69][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@E XXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[69][2],1,,,,.T.,)

	oTipoCon := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[70][1], aValoresN[70][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[70][2],1,,,,.T.,)

	oCodNif  := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[71][1], aValoresN[71][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@N 99999999999999999999999999999999999999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[71][2],1,,,,.T.,)

	oDataFim := TGet():New( 090, 001, {|u| if(PCount()==0, aValoresN[72][1], aValoresN[72][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[72][2],1,,,,.T.,)

	oDataIni := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[73][1], aValoresN[73][1]:=u)}, oTFolder:aDialogs[7], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[73][2],1,,,,.T.,)

	///////////////////////// ABA 'Autônomos' ///////////////////////

	oSubDiv  := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[83][1], aValoresN[83][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@R 9999.9999.999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[83][2],1,,,,.T.,)

	oDataN   := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[84][1], aValoresN[84][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[84][2],1,,,,.T.,)

	oSefip   := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[85][1], aValoresN[85][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[85][2],1,,,,.T.,)

	oOcorr   := TGet():New( 090, 001, {|u| if(PCount()==0, aValoresN[86][1], aValoresN[86][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[86][2],1,,,,.T.,)

	oCatEs   := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[87][1], aValoresN[87][1]:=u)}, oTFolder:aDialogs[8], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[87][2],1,,,,.T.,)

	///////////////////////// ABA 'Outros' ///////////////////////

	oPrior   := TGet():New( 000, 001, {|u| if(PCount()==0, aValoresN[88][1], aValoresN[88][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[88][2],1,,,,.T.,)

	oIdent   := TGet():New( 030, 001, {|u| if(PCount()==0, aValoresN[89][1], aValoresN[89][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[89][2],1,,,,.T.,)

	oRepres  := TGet():New( 060, 001, {|u| if(PCount()==0, aValoresN[90][1], aValoresN[90][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[90][2],1,,,,.T.,)

	oIdRep   := TGet():New( 090, 001, {|u| if(PCount()==0, aValoresN[91][1], aValoresN[91][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[91][2],1,,,,.T.,)

	oFabr    := TGet():New( 120, 001, {|u| if(PCount()==0, aValoresN[92][1], aValoresN[92][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[92][2],1,,,,.T.,)

	oCodLoc  := TGet():New( 150, 001, {|u| if(PCount()==0, aValoresN[93][1], aValoresN[93][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[93][2],1,,,,.T.,)

	oRecCid  := TGet():New( 180, 001, {|u| if(PCount()==0, aValoresN[95][1], aValoresN[95][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[95][2],1,,,,.T.,)

	oCodBlo  := TGet():New( 210, 001, {|u| if(PCount()==0, aValoresN[96][1], aValoresN[96][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[96][2],1,,,,.T.,)

	oProdRur := TGet():New( 240, 001, {|u| if(PCount()==0, aValoresN[97][1], aValoresN[97][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[97][2],1,,,,.T.,)

	oLcIss   := TGet():New( 270, 001, {|u| if(PCount()==0, aValoresN[99][1], aValoresN[99][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[99][2],1,,,,.T.,)

	oRecFa   := TGet():New( 300, 001, {|u| if(PCount()==0, aValoresN[100][1], aValoresN[100][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[100][2],1,,,,.T.,)

	oCCIC    := TGet():New( 000, 100, {|u| if(PCount()==0, aValoresN[101][1], aValoresN[101][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[101][2],1,,,,.T.,)

	oRecIma  := TGet():New( 030, 100, {|u| if(PCount()==0, aValoresN[102][1], aValoresN[102][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[102][2],1,,,,.T.,)

	oCodFIES := TGet():New( 060, 100, {|u| if(PCount()==0, aValoresN[103][1], aValoresN[103][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[103][2],1,,,,.T.,)

	oRgSimp  := TGet():New( 090, 100, {|u| if(PCount()==0, aValoresN[104][1], aValoresN[104][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[104][2],1,,,,.T.,)

	oRetCprb := TGet():New( 120, 100, {|u| if(PCount()==0, aValoresN[105][1], aValoresN[105][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[105][2],1,,,,.T.,)

	oIndRur  := TGet():New( 150, 100, {|u| if(PCount()==0, aValoresN[106][1], aValoresN[106][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[106][2],1,,,,.T.,)

	oInCult  := TGet():New( 180, 100, {|u| if(PCount()==0, aValoresN[108][1], aValoresN[108][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[108][2],1,,,,.T.,)

	oAssDesp := TGet():New( 210, 100, {|u| if(PCount()==0, aValoresN[109][1], aValoresN[109][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[109][2],1,,,,.T.,)

	oCalcInp := TGet():New( 240, 100, {|u| if(PCount()==0, aValoresN[110][1], aValoresN[110][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[110][2],1,,,,.T.,)

	oIdentPr := TGet():New( 270, 100, {|u| if(PCount()==0, aValoresN[111][1], aValoresN[111][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[111][2],1,,,,.T.,)

	oCliente := TGet():New( 300, 100, {|u| if(PCount()==0, aValoresN[112][1], aValoresN[112][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[112][2],1,,,,.T.,)

	oSimpNac := TGet():New( 330, 100, {|u| if(PCount()==0, aValoresN[113][1], aValoresN[113][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[113][2],1,,,,.T.,)

	oRfundes := TGet():New( 000, 200, {|u| if(PCount()==0, aValoresN[115][1], aValoresN[115][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[115][2],1,,,,.T.,)

	oIndPres := TGet():New( 030, 200, {|u| if(PCount()==0, aValoresN[116][1], aValoresN[116][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E X", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[116][2],1,,,,.T.,)

	oMjuridi := TGet():New( 060, 200, {|u| if(PCount()==0, aValoresN[117][1], aValoresN[117][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[117][2],1,,,,.T.,)

	oCodSc   := TGet():New( 090, 200, {|u| if(PCount()==0, aValoresN[118][1], aValoresN[118][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[118][2],1,,,,.T.,)

	oPesTri  := TGet():New( 120, 200, {|u| if(PCount()==0, aValoresN[120][1], aValoresN[120][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[120][2],1,,,,.T.,)

	oBlqTem  := TGet():New( 150, 200, {|u| if(PCount()==0, aValoresN[122][1], aValoresN[122][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@D", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[122][2],1,,,,.T.,)

	oCoSiaf  := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[123][1], aValoresN[123][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[123][2],1,,,,.T.,)

	oEndNo   :=	TGet():New( 210, 200, {|u| if(PCount()==0, aValoresN[124][1], aValoresN[124][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[124][2],1,,,,.T.,)

	oMotNif  := TGet():New( 240, 200, {|u| if(PCount()==0, aValoresN[125][1], aValoresN[125][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[125][2],1,,,,.T.,)

	oCliLoj  := TGet():New( 270, 200, {|u| if(PCount()==0, aValoresN[126][1], aValoresN[126][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[126][2],1,,,,.T.,)

	oClasPj  := TGet():New( 300, 200, {|u| if(PCount()==0, aValoresN[127][1], aValoresN[127][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[127][2],1,,,,.T.,)

	oCargo   := TGet():New( 330, 200, {|u| if(PCount()==0, aValoresN[128][1], aValoresN[128][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[128][2],1,,,,.T.,)

	oConf    := TGet():New( 000, 300, {|u| if(PCount()==0, aValoresN[129][1], aValoresN[129][1]:=u)}, oTFolder:aDialogs[9], 096, 009, "@E XXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,,,,,,.T.,.F.,, aValoresN[129][2],1,,,,.T.,)

	


	oButton3      := TButton():Create(oJanela, 340,1,"Fechar",{||oJanela:end()},75,20,,,,.T.,,,,,,)
	// ATIVANDO JANELA
	oJanela:Activate(,,,.T.,,,)




RETURN


Static Function verificaValores(aValores)
	Local aNomeValores := {}
	Local nI

	For nI := 1 to Len(aValores)
		valor := aValores[nI][1]
		nome := aValores[nI][2]

		If valor == ''
			AADD(aNomeValores,nome)
		Endif
	Next


RETURN aNomeValores


Static Function PRINTGRAPH()

	Local oReport as Object
	Local oSection as Object

	//Classe TREPORT
	oReport := TReport():New('Relatório',"Fornecedores",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection)})

	//Seção 1
	oSection := TRSection():New(oReport,'Fornecedores')

	//Definição das colunas de impressão da seção 1
	TRCell():New(oSection, "A2_NOME" , "SA2", "Nome", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TIPO", "SA2", "Tipo" , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CGC" , "SA2", "CGC/CPF"    , '@R 999.999.999-99', /*Tamanho*/,  , /*{|| code-block de impressao }*/)
	
	//Definição da collection
	//oColl:=TRCollection():New("TOTAL UF", "COUNT", /*oBreak*/,"Total POR UF",;
		///*cPicture*/, /*uFormula*/ oSection:Cell("A1_COD"), /*.lEndSection.*/ .F.,;
		///*.lEndReport.*/ .T., /*oParent*/ oSection, /*bCondition*/,;
		///*uContent*/ oSection:Cell("A1_EST") )

	//oReport:PrintGraphic()
	oReport:PrintDialog()

Return


Static Function ReportPrint(oReport, oSection)

	#IFDEF TOP

		Local cAlias := "SA2"

		BEGIN REPORT QUERY oSection

			BeginSql alias cAlias
            SELECT A2_NOME,A2_TIPO,A2_CGC
            FROM %table:SA2% 
			WHERE %notdel%
			EndSql

		END REPORT QUERY oSection

		//oSection:aCollection[1]:SetGraphic(4,"UF")
		oSection:PrintGraphic()
		oSection:Print()

	#ENDIF

return

Static Function PRINTCOMPLETEGRAPH()
	Local oReport as Object
	Local oSection as Object

	//Classe TREPORT
	oReport := TReport():New('Relatório',"Fornecedores",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection)})

	//Seção 1
	oSection := TRSection():New(oReport,'Fornecedores')

	//Definição das colunas de impressão da seção 1

	TRCell():New(oSection, "A2_COD" , "SA2", "Código", , /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_LOJA" , "SA2", "Loja", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_NOME" , "SA2", "Razão Social", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_EST" , "SA2", "Estado", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_MUN" , "SA2", "Municipio", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_END" , "SA2", "Endereço", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_NREDUZ" , "SA2", "Nome Fantasia", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TIPO" , "SA2", "Tipo", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TEL" , "SA2", "Telefone", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_PFISICA" , "SA2", "RG/Ced.Estr.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_INSCR" , "SA2", "Ins. Estad.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_INSCRM" , "SA2", "Ins. Municip.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DDI" , "SA2", "DDI", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_PAIS" , "SA2", "País", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DDD" , "SA2", "DDD", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DEPTO" , "SA2", "Departamento", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_EMAIL" , "SA2", "Email", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_HPAGE" , "SA2", "Homepage", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TELEX" , "SA2", "TELEX", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_ENDCOMP" , "SA2", "END. COMPLEMENTAR", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_MSBLQL" , "SA2", "Bloqueado", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_COMPLEM" , "SA2", "Complemento", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_FORNEMA" , "SA2", "Forn.Mailing", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CBO" , "SA2", "Cod CBO", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CNAE" , "SA2", "Cod CNAE", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_BANCO" , "SA2", "Banco", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_AGENCIA" , "SA2", "Cod. Agência", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_NUMCON" , "SA2", "Cta Corrente", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_NATUREZ" , "SA2", "Natureza", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_COND" , "SA2", "Cond. Pagto", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODADM" , "SA2", "CodAdm", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_FORMPAG" , "SA2", "Forma de pagamento", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DVCTA" , "SA2", "Dv Cta Cnab", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DVAGE" , "SA2", "DV Age Cnab", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TIPORUR" , "SA2", "Tp.Contr.Soc", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECISS" , "SA2", "Recolhe ISS", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODMUN" , "SA2", "Cod. Mun. ZF", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECINSS" , "SA2", "Calc. INSS", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TPESSOA" , "SA2", "Tipo Pessoa", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODPAIS" , "SA2", "País Bacen", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TPISSRS" , "SA2", "Tipo Escr.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_GRPTRIB" , "SA2", "Grp. Tribut.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECPIS" , "SA2", "Rec. PIS", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECCSLL" , "SA2", "Rec.CSLL", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECCOFI" , "SA2", "Rec.COFINS", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CALCIRF" , "SA2", "CÁLC. IRRF", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_VINCULO" , "SA2", "P. VINCULO", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DTINIV" , "SA2", "DT INI VINCU", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DTFIMV" , "SA2", "DT FIM VINCU", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RFACS" , "SA2", "REC. FACS", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CONTRIB" , "SA2", "Contribuinte", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RFABOV" , "SA2", "REC. FABOV", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DEDBSPC" , "SA2", "DED. PIS/COF", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECFMD" , "SA2", "REC. FAMAD", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CPOMSP" , "SA2", "REG. CPOM", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_SITESBH" , "SA2", "SITESPRES BH", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TPLOGR" , "SA2", "TP. LOGRAD", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TPJ" , "SA2", "TPJ", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DTCONV" , "SA2", "Dt. Conv", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CTARE" , "SA2", "Contr TARE?", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECFET" , "SA2", "Rec. FETHAB", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_MINIRF" , "SA2", "Vlr. Min. IR", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_INCLTMG" , "SA2", "Inc.Prd.Leit", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_FOMEZER" , "SA2", "Fome Zero", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_IRPROG" , "SA2", "IRRF Prog", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_INOVAUT" , "SA2", "Inovar Auto", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_NOMRESP" , "SA2", "Nome Resp.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CONTATO" , "SA2", "Contato", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TRANSP" , "SA2", "Transp.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CIVIL" , "SA2", "Estado Civil", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECSEST" , "SA2", "Recolhe SEST", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_PAISSUB" , "SA2", "SubDivPais", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TPCON" , "SA2", "Tipo Contrat", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_NIFEX" , "SA2", "Codigo NIF", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DTFIMR" , "SA2", "Data Fim", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DTINIR" , "SA2", "Data Inicio", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODNIT" , "SA2", "Num Insc Aut", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DTNASC" , "SA2", "Data nasc.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CATEG" , "SA2", "Categ. SEFIP", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_OCORREN" , "SA2", "Ocorrência", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CATEFD" , "SA2", "Cat eSocial", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_PRIOR" , "SA2", "Prioridade", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_ID_FBFN" , "SA2", "Identificac.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_REPRES" , "SA2", "Represent.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_ID_REPR" , "SA2", "Identif.Repr.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_FABRICA" , "SA2", "Fabricante", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODLOC" , "SA2", "Cod.Local", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RECCIDE" , "SA2", "Rec Cide", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODBLO" , "SA2", "Cod.Bloqueio", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_INDRUR" , "SA2", "Ind. Prod. Rur", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_ISSRSLC" , "SA2", "LC ISS RS", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RFASEMT" , "SA2", "Rec.FASE-MT", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CCICMS" , "SA2", "CCICMS", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RIMAMT" , "SA2", "Rec. IMA-MT", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODFI" , "SA2", "Cod. FIESP", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_REGESIM" , "SA2", "Rg. Simp. MT", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CPRB" , "SA2", "Ret. CPRB", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_INDCP" , "SA2", "Ind. Rural", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_INCULT" , "SA2", "Inc. Cultura", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_DESPORT" , "SA2", "Assoc. Desp.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CALCINP" , "SA2", "Calc.INSS.Pt", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_IMPIP" , "SA2", "Ident.Prod.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CLIENTE" , "SA2", "Cód. Cliente", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_SIMPNAC" , "SA2", "Opt Simp Nac", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_RFUNDES" , "SA2", "Rec.FUNDESA", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_PRSTSER" , "SA2", "Ind. Prest.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_MJURIDI" , "SA2", "M.Jurídico", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_MUNSC" , "SA2", "Cod Mun SC", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TRIBFAV" , "SA2", "Pes.Tri.Fav", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_MSBLQD" , "SA2", "BlqTemporal", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CODSIAF" , "SA2", "Cod.Mun.SIAF", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_ENDNOT" , "SA2", "End.Not.Form", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_MOTNIF" , "SA2", "Mot.NIF", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_LOJCLI" , "SA2", "Loja Cliente", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_TPENT" , "SA2", "Clas.PJ", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CARGO" , "SA2", "Cargo Resp.", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oSection, "A2_CONFFIS" , "SA2", "Conf. Física", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

	
	//Definição da collection
	//oColl:=TRCollection():New("TOTAL UF", "COUNT", /*oBreak*/,"Total POR UF",;
		///*cPicture*/, /*uFormula*/ oSection:Cell("A1_COD"), /*.lEndSection.*/ .F.,;
		///*.lEndReport.*/ .T., /*oParent*/ oSection, /*bCondition*/,;
		///*uContent*/ oSection:Cell("A1_EST") )

	//oReport:PrintGraphic()
	oReport:PrintDialog()
RETURN

Static Function CompleteReportPrint(oReport, oSection)
	#IFDEF TOP

		Local cAlias := "SA2"

		BEGIN REPORT QUERY oSection

			BeginSql alias cAlias
            SELECT *
            FROM %table:SA2% 
			WHERE %notdel%
			EndSql

		END REPORT QUERY oSection

		//oSection:aCollection[1]:SetGraphic(4,"UF")
		oSection:PrintGraphic()
		oSection:Print()

	#ENDIF

RETURN

Static Function verificaCgc(oTipo, oCGC, oCbo, oCnae, oCivil)
	Local nTipo := oTipo:nAt
	If nTipo == 1
		oCGC:Picture := "@R 999.999.999-99"
		oCbo:lReadOnly  := .F.
		oCnae:lReadOnly := .T.
		oCivil:lReadOnly := .F.
		oCivil:Select(1)
		oCnae:cText 	:= ''

	Else
		oCGC:Picture := "@R 99.999.999/9999-99"
		oCnae:lReadOnly := .F.
		oCbo:lReadOnly  := .T.
		oCivil:lReadOnly := .T.
		oCivil:Select(7)
		oCbo:cText 		:= ''

	Endif

RETURN

Static Function getMunicipios(oEstado)
	Local cQuery
	Local cEstado := AllTrim(FWGetSX5("12")[oEstado:nAt][3])
	Local aMunicipios := {}
	Local aMunicipiosTratado := {}
	Local nI


	cQuery := "SELECT CC2_MUN,CC2_CODMUN FROM "+ RetSqlName("CC2") + " WHERE CC2_EST LIKE '" + cEstado + "'"
	TCSqlToArr( cQuery, aMunicipios, , ,)

	For nI := 1 to len(aMunicipios)
		aMunicipiosTratado[nI] := AllTrim(aMunicipios[nI][1]) + ' - '  + aMunicipios[nI][2]
	Next

RETURN aMunicipiosTratado

Static Function getComboMunicipios(oEstado, oCodMunicipio)
	Local cQuery
	Local cEstado := AllTrim(FWGetSX5("12")[oEstado:nAt][3])
	Local aMunicipios := {}
	Local aMunicipiosTratado := {}
	Local nI


	cQuery := "SELECT CC2_MUN,CC2_CODMUN FROM "+ RetSqlName("CC2") + " WHERE CC2_EST LIKE '" + cEstado + "'"
	TCSqlToArr( cQuery, aMunicipios, , ,)


	For nI := 1 to len(aMunicipios)
		aMunicipiosTratado[nI] := AllTrim(aMunicipios[nI][1]) + ' - '  + aMunicipios[nI][2]
	Next

	oCodMunicipio:setItems(aMunicipiosTratado)

RETURN

Static Function getNomeMun(cCodMun, cEstado)
	Local cQuery
	Local aResult := {}

	cQuery := "SELECT CC2_MUN, CC2_CODMUN FROM "+ RetSqlName("CC2") + " WHERE CC2_CODMUN LIKE '" + cCodMun + "'" + "AND CC2_EST LIKE '" + cEstado + "'"
	TCSqlToArr( cQuery, aResult, , ,)

	If Len(aResult) < 1
		RETURN ''
	Endif

RETURN AllTrim(aResult[1][1]) + ' - ' + aResult[1][2]

Static Function trataCodMun(cCodMun)
	Local nPos
	nPos := At("-", cCodMun, 1)
RETURN Right(cCodMun, (Len(cCodMun)-nPos)-1)

Static Function trataNomeMun(cCodMun)
	Local nPos
	nPos := At("-", cCodMun, 1)
RETURN Left(cCodMun, (nPos-2))

Static Function getSiglaEst(cEstado)
	Local aEstados := FWGetSX5("12")
	Local cSigla
	Local nI

	For nI := 1 To Len(aEstados)
		If aEstados[nI][4] == cEstado
			cSigla := aEstados[nI][3]
			RETURN cSigla
		Endif
	Next



RETURN '00'

Static Function getPaises()
	Local cQuery
	Local aResult := {}


	cQuery := "SELECT YA_CODGI, YA_DESCR FROM "+ RetSqlName("SYA")
	TCSqlToArr( cQuery, aResult, , ,) //[1] = cod, [2] = nome

RETURN aResult

Static Function trataPaises()
	Local nI
	Local aPaises := getPaises()

	For nI := 1 to Len(aPaises)
		aPaises[nI] := AllTrim(aPaises[nI][2]) + ' - ' + aPaises[nI][1]
	next



RETURN aPaises

Static Function selecionaPais(oPais, cPais, aPaises)
	Local nI

	For nI := 1 To Len(aPaises)

		If trataCodMun(aPaises[nI]) == cPais
			oPais:Select(nI)
			RETURN
		Endif

	Next



RETURN

Static Function trocaDescPais(cCodPais, oDescPais)
	Local cNome := trataNomeMun(cCodPais)
	oDescPais:cText := cNome
RETURN

Static Function getPaisFromCod(cCodPais)
	Local cQuery
	Local aResult := {}

	cQuery := "SELECT YA_DESCR FROM "+ RetSqlName("SYA") + " WHERE YA_CODGI LIKE '" + cCodPais + "'"
	TCSqlToArr( cQuery, aResult, , ,)
	If Len(aResult) == 0
	Endif

RETURN AllTrim(aResult[1][1])

Static Function selecionaSimNao(oBloq, cBloq)
	If cBloq == '1'
		oBloq:nAt:= 2
	Else
		oBloq:nAt:= 1
	Endif
RETURN

Static Function selecionaNaoSim(oBloq, cBloq)
	If cBloq == '1'
		oBloq:nAt:= 1
	Else
		oBloq:Select(2)
	Endif
RETURN

Static Function getNatCondAdm(cDb)
	Local cQuery
	Local aResult := {}
	Local nI

	cQuery := "select * from " + RetSqlName(cDb)
	TCSqlToArr( cQuery, aResult, , ,)

	For nI := 1 To Len(aResult)
		aResult[nI] := AllTrim(aResult[nI][2])
	Next
RETURN aResult

Static Function getPagtos()
	Local aResult := {}
	Local nI

	aResult := FWGetSX5("58")

	For nI := 1 To Len(aResult)
		aResult[nI] := AllTrim(aResult[nI][4])
	Next

return aResult

Static Function getZF()
	Local aResult := {}
	Local nI

	aResult := FWGetSX5("S1")

	For nI := 1 To Len(aResult)
		aResult[nI] := AllTrim(aResult[nI][4])
	Next

return aResult

Static Function verificaTipoEscr(oTipoEscr)
	Local cTipoEscr := oTipoEscr:cText
	Local aTiposISSQN := { "01", "02", "03", "04", "05", "07", "08", "09", "10", "11", "12", "14", "15", "16", "17", "18", "19" }

	If AScan(aTiposISSQN, {|x| AllTrim(x) == cTipoEscr}) != 0
		RETURN
	Else
		FWAlertError("*Problema*: Tipo de Escrituração para o ISSQN de Porto Alegre/RS." + Chr(13) + Chr(10) + "01=Outro Tipo - Receita Bruta;" + Chr(13) + Chr(10) + "02=Agência de Publicidade e Propaganda;" + Chr(13) + Chr(10) + "03=Agência de Viagem e Operadora de Turismo;" + Chr(13) + Chr(10) + "04=Substituto Tributário Não Prestador de Serviços - Seg./Cia.Aérea;" + Chr(13) + Chr(10) + "05=Órgão da Administração Pública;" + Chr(13) + Chr(10) + "07=Sociedade de Profissionais;" + Chr(13) + Chr(10) + "08=Táxi e Transporte Escolar;" + Chr(13) + Chr(10) + "09=Regime Especial - Banco/Financeira/Corretora;" + Chr(13) + Chr(10) + "10=Equipamento Emissor de Cupom Fiscal;" + Chr(13) + Chr(10) + "11=Construção Civil / Incorporação Imobiliária;" + Chr(13) + Chr(10) + "12=Entidade Imune / Isenta;" + Chr(13) + Chr(10) + "14=Regime de Estimativa;" + Chr(13) + Chr(10) + "15=Receita Bruta com redução de Base de Cálculo;" + Chr(13) + Chr(10) + "16=Simples Nacional;" + Chr(13) + Chr(10) + "17=Planos de saúde;" + Chr(13) + Chr(10) + "18=Salões de beleza, barbearias e congêneres;" + Chr(13) + Chr(10) + "19=Escritório de Contabilidade - Simples Nacional.")
		oTipoEscr:cText := ''
		RETURN
	Endif

RETURN

Static Function trataFormaPag(cFormaPag)
	Local aResult := {}
	Local nI

	aResult := FWGetSX5("58")

	For nI := 1 To Len(aResult)
		If aResult[nI][4] == cFormaPag
			RETURN aResult[nI][3]
		Endif
	Next

RETURN

Static Function selecionaFormPagto(oFormaPagto, cFormaPag)
	Local aPagtos := {}
	Local nI

	aPagtos := FWGetSX5("58")

	For nI := 1 To Len(aPagtos)
		If AllTrim(aPagtos[nI][3]) == cFormaPag
			oFormaPagto:Select(nI)
		Endif
	Next

RETURN

Static Function trataCodZf(cZf)
	Local aZf := FWGetSX5("S1")
	Local nI

	For nI := 1 To Len(aZf)
		If aZf[nI][4] == AllTrim(cZf)
			RETURN AllTrim(aZf[nI][3])
		Endif
	Next
RETURN

Static Function selecionaTipoRUR(oTipoContr, cTipoRur)
	Local aContr := {"J", "F", "L"}
	oTipoContr:Select(AScan(aContr, cTipoRur))
RETURN


Static Function updateZf(oCodMunZf, cCodZf)
	Local aResult := {}
	Local nI

	aResult := FWGetSX5("S1")

	For nI := 1 To Len(aResult)
		If AllTrim(aResult[nI][3]) == cCodZf
			oCodMunZf:Select(nI)
			Exit
		Endif
	Next

RETURN


Static Function updateTipoPessoa(oTPessoa, cTipo)
	Local aTipoPessoa := {"CI", "PF", "OS"}

	oTPessoa:Select(AScan(aTipoPessoa, cTipo))
RETURN

Static Function getOpVinculo()
	Local cQuery
	Local aResult := {}
	Local nI

	cQuery := "select * from " + RetSqlName('CC1')
	TCSqlToArr( cQuery, aResult, , ,)

	For nI := 1 To Len(aResult)
		aResult[nI] := aResult[nI][2]
	Next

RETURN aResult


Static Function selecionaVal(oCombo, cValorCampo, aVetor)
	Local nI
	If AllTrim(cValorCampo) == ""
		RETURN 1
	Endif
	For nI := 1 To Len(aVetor)
		If Left(aVetor[nI],1) == cValorCampo
			oCombo:Select(nI)
		Endif
	Next
RETURN

Static Function getTransportadora()
	Local cQuery
	Local aResult := {}
	Local nI

	cQuery := "select * from " + RetSqlName('SA4')
	TCSqlToArr( cQuery, aResult, , ,)

	For nI := 1 To Len(aResult)
		aResult[nI] := AllTrim(aResult[nI][2])
	Next
RETURN

Static Function getIdent()
	Local aArray := FWGetSX5("48")
	Local nI

	For nI := 1 To Len(aArray)
		aArray[nI] := aArray[nI][4]
	Next

RETURN aArray


Static Function getCodLoc()
	Local aArray := FWGetSX5("AB")
	Local nI

	For nI := 1 To Len(aArray)
		aArray[nI] := aArray[nI][4]
	Next

RETURN aArray

Static Function getClientes()
	Local cQuery
	Local aResult := {}
	Local nI

	cQuery := "select a1_cod from " + RetSqlName('SA1')
	TCSqlToArr( cQuery, aResult, , ,)

	For nI := 1 To Len(aResult)
		aResult[nI] := AllTrim(aResult[nI][1])
	Next
RETURN aResult

Static Function verificacao(cod,loja)
	Local cQuery
	Local aResult := {}

	cQuery := "select a2_cod, a2_loja from " + RetSqlName('SA2') + " WHERE A2_COD LIKE '" + cod + "' AND A2_LOJA LIKE '" + loja + "'"
	TCSqlToArr( cQuery, aResult, , ,)

	If Len(aResult) > 0
		RETURN 1
	Else
		RETURN 0
	Endif

RETURN

Static Function selecionaCliente(cCliente, aClientes)
	Local nI

	For nI := 1 To Len(aClientes)
		If aClientes[nI] == cCliente
			RETURN nI
		Endif
	Next

RETURN 1
