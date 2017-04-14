function attributes(DataTypes) {
    return {
        key: {
            type: DataTypes.STRING,
            allowNull: false
        },
        value: {
            type: DataTypes.BOOLEAN,
            allowNull: false
        }
    };
}

module.exports = function(sequelize, DataTypes) {
    return sequelize.define('Service', attributes(DataTypes));
};
