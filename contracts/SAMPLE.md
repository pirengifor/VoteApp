// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Vote {
    /* Definimos la propuesta*/
    struct Proposal {
        string name; //nombre de la propuesta (candidato)
        uint votesCount; //cantidad de votos
    }
    /* Definimos al votante */
    struct Voter {
        bool voted; // true si esa persona ya ha votado
        uint vote; // índice de la propuesta votada
    }
    /* Array para traer todas las propuesta */
    Proposal[] public proposals;

    /* Solo la persona dueña del contrato */
    /* Puede agregar una propuesta */
    /* Esta es "chairperson" */
    address chairperson;

    /* Utilizamos mapping para almacenar y recuperar los
    datos de los votantes y quienes ya votaron,
    espeficicante este mapping será por la dirección de la billetera
    (wallet address) de cada votante*/
    mapping(address => Voter) public voters;
    /* Definimos un "modificador" para que solo el admin pueda
    agregar una propuesta */
    modifier onlyAdministrator() {
        require(
            msg.sender == chairperson,
            "the caller of this function must be the administrator"
        );
        _;
    }
    /* Definimos un "modificador" para los que no realizaron
    su voto aún*/
    modifier onlyUsersNotVotedYet() {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted");
        _;
    }

    /* Solo el dueño del contrato tiene poder sobre el mismo,
    siendo la misma persona que hizo el deploy (despliegue)*/
    constructor() {
        chairperson = msg.sender; //msg: variable global
    }

    /* Agregamos las propuestas */
    function addProposal(string memory _name) public onlyAdministrator {
        proposals.push(Proposal({
            name: _name, //nombre de la propuesta (candidato)
            votesCount: 0 //cantidad de votos
            }));
    }
    /* Función para poder visualizar cauntas propuestas hay*/
    function getProposals() public view returns (uint256) {
        return proposals.length;
    }
    /* Función para poder visualizar todas las propuestas*/
    function getInfoProposals() public view returns (Proposal[] memory) {
        return proposals;
    }
    /* Función para poder visualizar quien esta a cargo o a quien
    pertece el contrato */
    function getChairPerson() public view returns (address) {
        return chairperson;
    }
    /* Definimos una función para los votantes */
    function vote(uint32 index) public onlyUsersNotVotedYet {
        Voter storage sender = voters[msg.sender];
        proposals[index].votesCount += 1;
        sender.voted = true;
        sender.vote = index;
    }
    /* Función para poder visualizar el número de votos por propuesta*/
    function getVotesById(uint index) public view returns (uint256) {
        return proposals[index].votesCount;
    }
}
