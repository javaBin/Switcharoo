function attributes(DataTypes) {
    return {
        key: {
            type: DataTypes.STRING,
            allowNull: false
        },
        hint: {
            type: DataTypes.STRING,
            allowNull: false
        },
        value: {
            type: DataTypes.JSON,
            allowNull: false
        }
    };
}

module.exports = function(sequelize, DataTypes) {
    return sequelize.define('Setting', attributes(DataTypes));
};
