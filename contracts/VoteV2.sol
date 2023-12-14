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
        uint idParty; // FK_PARTY
        uint idFaculty; //FK_FACULTY
    }
    struct InfoCandidate {
        uint idCandidate;
        string name;
        Party party;
        Faculty faculty;
        
    }
    struct Voter {
        uint idVoter; // PK
        address identificador;
        bool voted; // true si esa persona ya ha votado
        uint vote; // índice de la propuesta votada
        uint idElection;
    }
    struct InfoVoter {
        uint idVoter; // PK
        address identificador;
        bool voted; // true si esa persona ya ha votado
        uint vote; // índice de la propuesta votada
        Election election;
    }
    struct ElectionCandidate {
        uint idElectionPartyCandidate; // PK
        uint idElection; // FK_ELECTION
        uint idCandidate; // FK_CANDIDATE
        uint votesCount;
    }
    struct DetalleResultados {
        uint idElectionPartyCandidate; // PK
        Election election; // FK_ELECTION
        InfoCandidate candidate; // FK_CANDIDATE
        uint votesCount;
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

    modifier onlyUsersNotVotedYet(uint electionId) {
    bool hasVoted = false;

    for (uint i = 0; i < voters.length; i++) {
        if (voters[i].identificador == msg.sender && voters[i].idElection == electionId && voters[i].voted) {
            hasVoted = true;
            break;
        }
    }

    require(!hasVoted, "El votante ya ha votado en esta election.");
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
                idFaculty: indexFaculty
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
                idCandidate:indexCandidate, // FK_PARTY
                votesCount:0
            })
        );

        // Asigna el nuevo ideleccionesCandidates al índice correspondiente
        eleccionescandidatesIndex[nextIdElectionPartyCandidate] = asignacioneleccions.length - 1;

        // Incrementa el contador interno para el próximo idCandidates
        nextIdElectionPartyCandidate++;
    }

    function registerVoter(address identifier, uint electionId) public onlyUsersNotVotedYet(electionId) {
        Voter memory newVoter = Voter({
            idVoter: voters.length,
            identificador: identifier,
            voted: true, // Marcamos al votante como que ya ha votado
            vote: 0, // Puedes inicializarlo con un valor predeterminado o dejarlo en 0
            idElection: electionId
        });

        // Agregamos al votante al arreglo de votantes
        voters.push(newVoter);

        // Mapeamos la dirección del votante a su información en el mapeo mapVoters
        mapVoters[identifier] = newVoter;
    }

    function Votante(uint indexCandidato, uint indexElection) public onlyUsersNotVotedYet(indexElection) {
    Voter storage sender = mapVoters[msg.sender];

        registerVoter(msg.sender, indexElection);

         // Obtener el índice del votante en el arreglo voters
        uint electioncandidatoIndex;
        for (uint i = 0; i < asignacioneleccions.length; i++) {
            if (asignacioneleccions[i].idCandidate == indexCandidato && asignacioneleccions[i].idElection == indexElection) {
                electioncandidatoIndex = i;
                break;
            }
        }
        asignacioneleccions[electioncandidatoIndex].votesCount++;
        sender.voted = true;
        sender.idElection = indexElection;
        sender.vote = indexCandidato;
    

    // Marcar al votante como que ya ha votado en esta elección
    
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
                })
                
            }),
            votesCount: asignacioneleccions[i].votesCount
        });
    }

    return electionscandidatesWithInfo;
    }

    
    
    // Cantidad de Candidatos
    function getNumberCandidates() public view returns (uint) {
        return candidates.length;
    }

    function getCandidatesAndVotes(uint electionId) public view returns (uint[] memory candidateAndVotePairs) {
    // Declarar un array dinámico para almacenar pares de candidato y voto
    uint[] memory _candidateAndVotePairs = new uint[](asignacioneleccions.length * 2);

    uint pairIndex = 0;

    // Iterar sobre el array de candidatos y obtener la información para la elección específica
    for (uint i = 0; i < asignacioneleccions.length; i++) {
        if (asignacioneleccions[i].idElection == electionId) {
                // Almacenar el id del candidato
                _candidateAndVotePairs[pairIndex] = asignacioneleccions[i].idCandidate;
                pairIndex++;

                // Almacenar el conteo de votos para el candidato
                _candidateAndVotePairs[pairIndex] = asignacioneleccions[i].votesCount;
                pairIndex++;
            }
        }

        // Redimensionar el array resultante
        uint[] memory result = new uint[](pairIndex);
        for (uint j = 0; j < pairIndex; j++) {
            result[j] = _candidateAndVotePairs[j];
        }

        // Devolver el array resultante
        return result;
    }
}
