// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Vote {
   /* ---------------------- ESTRUCTURAS ------------------------------*/
    struct Election {
        uint idElection;
        string name;
        uint year;
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
        uint votesCount;
        uint idParty; // FK_PARTY
        uint idFaculty; //FK_FACULTY
    }
    struct InfoCandidate {
        uint idCandidate;
        string name;
        uint256 votesCount;
        Party party;
        Faculty faculty;
        
    }
    struct Voter {
        uint idVoter; // PK
        string name;
        uint dni;
        bool voted; // true si esa persona ya ha votado
        uint vote; // índice de la propuesta votada
        uint idFaculty; //FK_FACULTY
    }
    struct InfoVoter {
        uint idVoter; // PK
        string name;
        uint dni;
        bool voted; // true si esa persona ya ha votado
        uint vote; // índice de la propuesta votada
        Faculty faculty; //FK_FACULTY
    }
    struct ElectionCandidate {
        uint idElectionPartyCandidate; // PK
        uint idElection; // FK_ELECTION
        uint idCandidate; // FK_CANDIDATE
    }
    struct DetalleResultados {
        uint idElectionPartyCandidate; // PK
        Election election; // FK_ELECTION
        InfoCandidate candidate; // FK_CANDIDATE
    }
    
    /* ---------------------- ARREGLOS -----------------------------------*/
    Election[] private elections;
    Party[] private parties;
    Faculty[] private faculties;
    Candidate[] private candidates; // Proposal
    //InfoCandidate[] private infocandidates; // Proposal
    Voter[] private voters;
    ElectionCandidate[] private asignacioneleccions;
    //listaCandidatos[] private lista;

    /* ---------------------- MAPEOS -------------------------------------*/
    mapping(uint => uint) private electionsIndex; // Mapeo de ID de elecciones a ├¡ndices de elecciones
    mapping(uint => uint) private partiesIndex; // Mapeo de ID de partidos a ├¡ndices de partidos
    mapping(uint => uint) private facultiesIndex; // Mapeo de nombres de facultades a ├¡ndices de facultades
    mapping(uint => uint) private candidatesIndex; // Mapeo de ID de candidatos a ├¡ndices de candidatos
    mapping(uint => uint) private eleccionescandidatesIndex;
    mapping(address => Voter) private mapVoters; // Mapeo de direcciones a votantes

    /* ------------------ VARIABLES PUBLICAS -----------------------------*/
    // Declarar la variable owner
    address public owner;
    // Contador interno para el ids
    uint private nextIdFaculties;
    uint private nextIdParties;
    uint private nextIdElections;
    uint private nextIdCandidates;
    uint private nextIdElectionPartyCandidate;
    

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
        require(!sender.voted, "El votante ya ha votado.");
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
                nameBytes[i] != 0x20 && //espacio
                nameBytes[i] != 0x09 && //tab
                nameBytes[i] != 0x0A && //enter
                nameBytes[i] != 0x0D    // borrar
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
        for (uint i = 0; i < faculties.length; i++) {
            // Compara si el nombre actual en 'parties' es igual al nombre dado
            if (
                keccak256(abi.encodePacked(faculties[i].name)) ==
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
        elections.push(Election({name: name, idElection: nextIdElections, year: year}));

        // Asigna el nuevo idParty al índice correspondiente
        electionsIndex[nextIdElections] = elections.length - 1;

        // Incrementa el contador interno para el próximo idElection
        nextIdElections++;
    }

    // Crear Partido
    function addParty(string memory name) public onlyOwner {
        require(
            isIdNombreValidoEUnicoEnParties(name),
            "Nombre del partido no valido o repetido"
        );

        // Agrega una nueva instancia de Party al array
        parties.push(Party({name: name, idParty: nextIdParties}));

        // Asigna el nuevo idParty al índice correspondiente
        partiesIndex[nextIdParties] = parties.length - 1;

        // Incrementa el contador interno para el próximo idParty
        nextIdParties++;
    }

    // Crear Facultad
    function addFaculty(string memory name) public onlyOwner {
        require(
            isIdNombreValidoEUnicoEnParties(name),
            "Nombre del partido no valido o repetido"
        );

        // Agrega una nueva instancia de Faculty al array
        faculties.push(Faculty({name: name, idFaculty: nextIdFaculties}));

        // Asigna el nuevo idParty al índice correspondiente
        facultiesIndex[nextIdFaculties] = faculties.length - 1;

        // Incrementa el contador interno para el próximo idFaculty
        nextIdFaculties++;
    }

    // Crear Candidato
    function addCandidate(string memory name,uint indexParty,uint indexFaculty) public onlyOwner {
        /* require(
            isIdNombreValidoEUnicoEnParties(name),
            "Nombre del partido no valido o repetido"
        ); */

        // Agrega una nueva instancia de Candidates al array
        candidates.push(
            Candidate({
                name: name,
                idCandidate: nextIdCandidates,
                idParty: indexParty,
                idFaculty: indexFaculty,
                votesCount: 0
            })
        );

        // Asigna el nuevo idCandidates al índice correspondiente
        candidatesIndex[nextIdCandidates] = candidates.length - 1;

        // Incrementa el contador interno para el próximo idCandidates
        nextIdCandidates++;
    }

    function addElectionPartyCandidate(
            uint32 indexCandidate,
            uint32 indexElection) public onlyOwner {
        /* require(
            isIdNombreValidoEUnicoEnParties(name),
            "Nombre del partido no valido o repetido"
        ); */

        // Agrega una nueva instancia de Candidates al array
        asignacioneleccions.push(
            ElectionCandidate({
                idElectionPartyCandidate:nextIdElectionPartyCandidate,
                idElection:indexElection, // FK_ELECTIO
                idCandidate:indexCandidate // FK_PARTY
            })
        );

        // Asigna el nuevo ideleccionesCandidates al índice correspondiente
        eleccionescandidatesIndex[nextIdElectionPartyCandidate] = asignacioneleccions.length - 1;

        // Incrementa el contador interno para el próximo idCandidates
        nextIdElectionPartyCandidate++;
    }

    function Votante(uint index) public onlyUsersNotVotedYet {
        Voter storage sender = mapVoters[msg.sender];
        candidates[index].votesCount++;

        // Agrega logs para seguimiento
        emit VotoRegistrado(msg.sender, index);

        sender.voted = true;
        sender.vote = index;
    }
    // Agrega este evento al contrato
event VotoRegistrado(address indexed votante, uint indexed indiceCandidato);

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
    function getNumberElections() public view returns (uint) {
        return elections.length;
    }

    // Obtener lista de Partidos
    function getParties() public view returns (Party[] memory) {
        return parties;
    }

    // Obtener cantidad de Partidos
    function getNumberParties() public view returns (uint) {
        return parties.length;
    }

    // Lista de Facultades
    function getFaculties() public view returns (Faculty[] memory) {
        return faculties;
    }

    // Cantidad de Facultades
    function getNumberFaculties() public view returns (uint) {
        return faculties.length;
    }

    
    // Lista de Candidatos
  function getCandidates() public view returns (InfoCandidate[] memory) {
    InfoCandidate[] memory candidatesWithInfo = new InfoCandidate[](candidates.length);

    for (uint i = 0; i < candidates.length; i++) {
        candidatesWithInfo[i] = InfoCandidate({
            name: candidates[i].name,
            idCandidate: candidates[i].idCandidate,
            votesCount: candidates[i].votesCount,
            party: Party({
                idParty: parties[candidates[i].idParty].idParty,
                name: parties[candidates[i].idParty].name
            }),
            faculty: Faculty({
                idFaculty: faculties[candidates[i].idFaculty].idFaculty,
                name: faculties[candidates[i].idFaculty].name
            })
        });
    }

    return candidatesWithInfo;
    }

    function getelectionsCandidates() public view returns (DetalleResultados[] memory) {
    DetalleResultados[] memory electionscandidatesWithInfo = new DetalleResultados[](asignacioneleccions.length);

    for (uint i = 0; i < asignacioneleccions.length; i++) {
        electionscandidatesWithInfo[i] = DetalleResultados({
            idElectionPartyCandidate: asignacioneleccions[i].idElectionPartyCandidate,
            election: Election({
                idElection: elections[asignacioneleccions[i].idElection].idElection,
                name: elections[asignacioneleccions[i].idElection].name,
                year: elections[asignacioneleccions[i].idElection].year
            }),
            candidate: InfoCandidate({
                idCandidate: candidates[asignacioneleccions[i].idCandidate].idCandidate,
                name: candidates[asignacioneleccions[i].idCandidate].name,
                party: Party({
                    idParty: parties[candidates[asignacioneleccions[i].idCandidate].idParty].idParty,
                    name: parties[candidates[asignacioneleccions[i].idCandidate].idParty].name
                }),
                faculty: Faculty({
                    idFaculty: faculties[candidates[asignacioneleccions[i].idCandidate].idFaculty].idFaculty,
                    name: faculties[candidates[asignacioneleccions[i].idCandidate].idFaculty].name
                }),
                votesCount: candidates[asignacioneleccions[i].idCandidate].votesCount
            })
        });
    }

    return electionscandidatesWithInfo;
    }

    
    
    // Cantidad de Candidatos
    function getNumberCandidates() public view returns (uint) {
        return candidates.length;
    }
}
