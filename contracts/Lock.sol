// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Vote {
    /* ---------------------- ESTRUCTURAS ------------------------------*/
    struct Election {
        uint idElection;
        string name;
        uint256 year;
    }
    struct Party {
        uint idParty;
        string name;
    }
    struct Faculty {
        uint idFaculty; // PK
        string name;
    }
    struct Candidate {
        uint idCandidate; // PK
        string name;
        uint256 votesCount;
        uint idParty; // FK_PARTY
        uint idFaculty; //FK_FACULTY
    }
    struct Voter {
        uint idVoter; // PK
        string name;
        uint dni;
        uint256 votesCount;
        bool voted; // true si esa persona ya ha votado
        uint vote; // índice de la propuesta votada
        uint idFaculty; //FK_FACULTY
    }
    struct DetailElectionPartyCandidate {
        uint idDetailElectionPartyCandidate; // PK
        uint idElection; // FK_ELECTION
        uint idParty; // FK_PARTY
        uint idCandidate; // FK_CANDIDATE
        uint votes; // Cantidad de votos
    }
    /* ---------------------- ARREGLOS -----------------------------------*/
    Election[] private elections;
    Party[] private parties;
    Faculty[] private faculties;
    Candidate[] private candidates; // Proposal
    Voter[] private voters;

    /* ---------------------- MAPEOS -------------------------------------*/
    mapping(uint256 => uint256) private electionsIndex; // Mapeo de ID de elecciones a ├¡ndices de elecciones
    mapping(uint256 => uint256) private partiesIndex; // Mapeo de ID de partidos a ├¡ndices de partidos
    mapping(uint256 => uint256) private facultiesIndex; // Mapeo de nombres de facultades a ├¡ndices de facultades
    mapping(uint256 => uint256) private candidatesIndex; // Mapeo de ID de candidatos a ├¡ndices de candidatos
    mapping(address => Voter) private mapVoters; // Mapeo de direcciones a votantes

    /* ------------------ VARIABLES PUBLICAS -----------------------------*/
    // Declarar la variable owner
    address public owner;
    // Contador interno para el ids
    uint private nextId;
    /* ---------------------- MODIFICADORES -------------------------------*/
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Solo el propietario puede ejecutar esta funcion."
        );
        _;
    }

    modifier onlyUsersNotVotedYet() {
        Voter storage sender = mapVoters[msg.sender];
        require(sender.voted, "El votante ya ha votado.");
        _;
    }

    /* ---------------------- CONSTRUCTOR ---------------------------------*/
    constructor() {
        owner = msg.sender;
    }

    /* ---------------------------- FUNCIONES -----------------------------*/

    //\\//\\//\\//\\//\\\\//\\ --- VALIDACIONES --- //\\//\\//\\//\\//\\//\\/
    /*                              PARTIDO                                */
    // Verifica si el nombre es unico, no repetido y no vacio para Partidos
    function isIdNombreValidoEUnicoEnParties(
        string memory name
    ) internal view returns (bool) {
        // Verifica si la cadena está vacía o solo contiene espacios en blanco
        bytes memory nameBytes = bytes(name);
        bool esNombreValido = false;
        for (uint i = 0; i < nameBytes.length; i++) {
            if (
                nameBytes[i] != 0x20 &&
                nameBytes[i] != 0x09 &&
                nameBytes[i] != 0x0A &&
                nameBytes[i] != 0x0D
            ) {
                esNombreValido = true;
                break;
            }
        }
        if (!esNombreValido) {
            return false; // El nombre es solo espacios en blanco
        }
        // Recorre todos los elementos en el array 'parties'
        for (uint i = 0; i < parties.length; i++) {
            // Compara si el nombre actual en 'parties' es igual al nombre dado
            if (
                keccak256(abi.encodePacked(parties[i].name)) ==
                keccak256(abi.encodePacked(name))
            ) {
                // El nombre ya existe en 'parties'
                return false;
            }
        }
        // El nombre es válido y único en 'parties'
        return true;
    }

    // TO WRITE IN THE CONTRACT

    // Crear Eleccion
    function addElection(string memory name, uint year) public onlyOwner {
        /* require(
            isIdNombreValidoEUnicoEnParties(name, nextElectionId),
            "Nombre de la eleccion no valido o repetido"
        ); */

        // Agrega una nueva instancia de Election al array
        elections.push(Election({name: name, idElection: nextId, year: year}));

        // Asigna el nuevo idParty al índice correspondiente
        electionsIndex[nextId] = elections.length - 1;

        // Incrementa el contador interno para el próximo idElection
        nextId++;
    }

    // Crear Partido
    function addParty(string memory name) public onlyOwner {
        require(
            isIdNombreValidoEUnicoEnParties(name),
            "Nombre del partido no valido o repetido"
        );

        // Agrega una nueva instancia de Party al array
        parties.push(Party({name: name, idParty: nextId}));

        // Asigna el nuevo idParty al índice correspondiente
        partiesIndex[nextId] = parties.length - 1;

        // Incrementa el contador interno para el próximo idParty
        nextId++;
    }

    // Crear Facultad
    function addFaculty(string memory name) public onlyOwner {
        require(
            isIdNombreValidoEUnicoEnParties(name),
            "Nombre del partido no valido o repetido"
        );

        // Agrega una nueva instancia de Faculty al array
        faculties.push(Faculty({name: name, idFaculty: nextId}));

        // Asigna el nuevo idParty al índice correspondiente
        facultiesIndex[nextId] = faculties.length - 1;

        // Incrementa el contador interno para el próximo idFaculty
        nextId++;
    }

    // Crear Candidato
    function addCandidate(string memory name) public onlyOwner {
        require(
            isIdNombreValidoEUnicoEnParties(name),
            "Nombre del partido no valido o repetido"
        );

        // Agrega una nueva instancia de Candidates al array
        candidates.push(
            Candidate({
                name: name,
                idCandidate: nextId,
                idParty: 0,
                idFaculty: 0,
                votesCount: 0
            })
        );

        // Asigna el nuevo idCandidates al índice correspondiente
        candidatesIndex[nextId] = candidates.length - 1;

        // Incrementa el contador interno para el próximo idCandidates
        nextId++;
    }

    function Votante(uint32 index) public onlyUsersNotVotedYet {
        Voter storage sender = mapVoters[msg.sender];
        candidates[index].votesCount += 1;
        sender.voted = true;
        sender.vote = index;
    }

    /* ---------------------------------------------------------------------------- */
    /* TO READ IN THE CONTRACT */
    // Obtener el dueño del contrato
    function getOwner() public view returns (address) {
        return owner;
    }

    //  --- Obtener Eleccion
    // Lista de elecciones
    function getElections() public view returns (Election[] memory) {
        return elections;
    }

    // Cantidad de elecciones
    function getNumberElections() public view returns (uint256) {
        return elections.length;
    }

    // Obtener lista de Partidos
    function getParties() public view returns (Party[] memory) {
        return parties;
    }

    // Obtener cantidad de Partidos
    function getNumberParties() public view returns (uint256) {
        return parties.length;
    }

    // Lista de Facultades
    function getFaculties() public view returns (Faculty[] memory) {
        return faculties;
    }

    // Cantidad de Facultades
    function getNumberFaculties() public view returns (uint256) {
        return faculties.length;
    }
    // Lista de Candidatos
    function getCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    // Cantidad de Candidatos
    function getNumberCandidates() public view returns (uint256) {
        return candidates.length;
    }
}
